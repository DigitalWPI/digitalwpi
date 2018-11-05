import os
import logging
import sqlite3
import pysftp
import shutil
import zipfile
import xml.etree.ElementTree as ElementTree
from xml.dom import minidom
import pymarc
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email import encoders
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
import smtplib
import tempfile
import json
from bs4 import BeautifulSoup
import argparse
import subprocess

log = logging.getLogger(__name__)

language_map = {
    'CH': 'chi',
    'DU': 'dut',
    'FI': 'fin',
    'FR': 'fre',
    'GE': 'ger',
    'GR': 'gre',
    'HE': 'heb',
    'IT': 'ita',
    'JA': 'jpn',
    'KO': 'kor',
    'LA': 'lat',
    'PL': 'pol',
    'PR': 'por',
    'RU': 'rus',
    'SP': 'spa',
    'SW': 'swe'
}


class EtdLoader:
    def __init__(self, base_path,
                 etd_ftp_host, etd_ftp_username, etd_ftp_password, etd_ftp_path, etd_ftp_port,
                 mail_host, mail_username, mail_password, mail_port, marc_mail_to, ingest_path,
                 ingest_command, ingest_depositor, repository_base_url, debug_mode, dry_run):
        log.info('Base path is %s', base_path)
        self.base_path = base_path
        # Contains ETD files that have been retrieved from ETD FTP
        self.etd_store_path = os.path.join(self.base_path, 'etd_store')
        if not os.path.exists(self.etd_store_path):
            os.makedirs(self.etd_store_path)

        # Contains files to be imported into repository
        self.import_store_path = os.path.join(self.base_path, 'import_store')
        if not os.path.exists(self.import_store_path):
            os.makedirs(self.import_store_path)

        # Contains previously created MARC records
        self.marc_store_path = os.path.join(self.base_path, 'marc_store')
        if not os.path.exists(self.marc_store_path):
            os.makedirs(self.marc_store_path)

        # Contains ETD files that are to be imported into repository
        self.etd_to_be_imported_path = os.path.join(self.base_path, 'etd_to_be_imported')
        if not os.path.exists(self.etd_to_be_imported_path):
            os.makedirs(self.etd_to_be_imported_path)

        # Contains ETD files that are to be crosswalked to MARC records
        self.etd_to_be_marced_path = os.path.join(self.base_path, 'etd_to_be_marced')
        if not os.path.exists(self.etd_to_be_marced_path):
            os.makedirs(self.etd_to_be_marced_path)

        self.store = IdStore(self.base_path)

        self.now = datetime.now()
        self.marc_temp_filepath = os.path.join(self.base_path, 'etd.mrc')
        self.marc_record_filename = "etd-{}.mrc".format(self.now.strftime('%Y%m%d-%H%M%S'))
        self.marc_record_filepath = os.path.join(self.marc_store_path, self.marc_record_filename)

        self.etd_ftp_host = etd_ftp_host
        self.etd_ftp_username = etd_ftp_username
        self.etd_ftp_password = etd_ftp_password
        self.etd_ftp_path = etd_ftp_path
        self.etd_ftp_port = etd_ftp_port

        self.mail_host = mail_host
        self.mail_username = mail_username
        self.mail_password = mail_password
        self.mail_port = mail_port
        self.marc_mail_to = marc_mail_to

        self.ingest_path = ingest_path
        self.ingest_command = ingest_command
        self.ingest_depositor = ingest_depositor
        self.repository_base_url = repository_base_url

        self.debug_mode = debug_mode
        self.dry_run = dry_run

    def retrieve_etd_files(self):
        """
        Retrieves ETD files from ETD FTP using SFTP.

        Files are retrieved if a file with the same name does not exist in etd_store.
        """
        log.info("Retrieving ETD files from %s (%s) to %s", self.etd_ftp_host, self.etd_ftp_path, self.etd_store_path)
        # Get list of files in etd_store
        etd_store_files = set(os.listdir(self.etd_store_path))

        with pysftp.Connection(self.etd_ftp_host, username=self.etd_ftp_username, password=self.etd_ftp_password,
                               port=self.etd_ftp_port) as sftp:
            with sftp.cd(self.etd_ftp_path):
                etd_ftp_files = set()
                for etd_file in sftp.listdir():
                    if sftp.isfile(etd_file) and etd_file.lower().endswith('.zip'):
                        etd_ftp_files.add(etd_file)
                etd_ftp_retrieve_files = etd_ftp_files - etd_store_files
                log.info("Retrieving %s new ETD files", len(etd_ftp_retrieve_files))
                for etd_file in etd_ftp_retrieve_files:
                    log.info('Getting %s', etd_file)
                    sftp.get(etd_file, localpath=os.path.join(self.etd_store_path, etd_file))
                    # Copy to additional locations
                    shutil.copy(os.path.join(self.etd_store_path, etd_file), self.etd_to_be_imported_path)
                    shutil.copy(os.path.join(self.etd_store_path, etd_file), self.etd_to_be_marced_path)

    def create_marc_records(self):
        log.info('Creating MARC records')
        with open(self.marc_temp_filepath, 'ab') as marc_record_file:
            for etd_filename in os.listdir(self.etd_to_be_marced_path):
                etd_id = self._extract_etd_id_from_filename(etd_filename)
                try:
                    # If there is not an existing repository id, then skip.
                    if etd_id not in self.store:
                        log.info('%s does not have repository id, so not creating MARC record', etd_id)
                    # Otherwise, extract XML metadata file and crosswalk to MARC
                    else:
                        record = self.create_marc_record(etd_filename, self.store[etd_id])
                        marc_record_file.write(record.as_marc())
                    # Now delete it
                    os.remove(os.path.join(self.etd_to_be_marced_path, etd_filename))
                except EtdLoaderException as e:
                    log.error("Error creating MARC record for %s: %s", etd_filename, e)
        # If not empty
        if os.path.getsize(self.marc_temp_filepath):
            # Send email
            self._mail_marc_record_file()
            # Move it
            os.rename(self.marc_temp_filepath, self.marc_record_filepath)

    def create_marc_record(self, etd_filename, repository_id):
        log.info('Creating MARC record from %s', etd_filename)
        return self._create_marc_record(
            self._extract_metadata_file(os.path.join(self.etd_to_be_marced_path, etd_filename)), etd_filename,
            repository_id)

    def _create_marc_record(self, metadata_tree, etd_filename, repository_id):
        running_date = self.now.strftime('%Y%m%d')
        record = pymarc.Record()
        record.leader = '00000nam a22000007a 4500'
        record.add_ordered_field(
            pymarc.Field(
                tag='001',
                data='etd_{}'.format(self._extract_etd_id_from_filename(etd_filename))
            ),
            pymarc.Field(
                tag='003',
                data='MiAaPQ'
            ),
            pymarc.Field(
                tag='006',
                data='m    fo  d        '
            ),
            pymarc.Field(
                tag='007',
                data='cr mnu   aacaa'
            ),
            pymarc.Field(
                tag='040',
                indicators=[' ', ' '],
                subfields=[
                    'a', 'MiAaPQ',
                    'b', 'eng',
                    'c', 'DGW',
                    'd', 'DGW'
                ]),
            pymarc.Field(
                tag='049',
                indicators=[' ', ' '],
                subfields=[
                    'a', 'DGWW'
                ]
            ),
            pymarc.Field(
                tag='504',
                indicators=[' ', ' '],
                subfields=[
                    'a', 'Includes bibliographical references.'
                ]
            ),
            pymarc.Field(
                tag='538',
                indicators=[' ', ' '],
                subfields=[
                    'a', 'Mode of access: Internet'
                ]
            ),
            pymarc.Field(
                tag='852',
                indicators=['8', ' '],
                subfields=[
                    'b', 'gwg ed',
                    'h', 'GW: Electronic Dissertation'
                ]
            ),
            pymarc.Field(
                tag='856',
                indicators=['4', '0'],
                subfields=[
                    'u', '{}{}'.format(self.repository_base_url, repository_id),
                    'z', 'Click here to access.'
                ]),
            pymarc.Field(
                tag='996',
                indicators=[' ', ' '],
                subfields=[
                    'a', 'New title added ; {}'.format(running_date)
                ]
            ),
            pymarc.Field(
                tag='998',
                indicators=[' ', ' '],
                subfields=[
                    'c', 'gwjshieh ; UMI-ETDxml conv ; {}'.format(running_date)
                ]
            )
        )

        description_node = metadata_tree.find('DISS_description[@page_count]')
        if description_node is not None:
            record.add_ordered_field(
                pymarc.Field(
                    tag='516',
                    indicators=[' ', ' '],
                    subfields=[
                        'a', 'Text (PDF: {} p.)'.format(description_node.get('page_count'))
                    ]
                )
            )
        raw_abstract_text = ""
        for para_elem in metadata_tree.findall('DISS_content/DISS_abstract/DISS_para'):
            raw_abstract_text += para_elem.text
        abstract_text = BeautifulSoup(raw_abstract_text, 'html.parser').text
        if abstract_text:
            record.add_ordered_field(
                pymarc.Field(
                    tag='520',
                    indicators=['3', ' '],
                    subfields=[
                        'a', abstract_text
                    ]
                )
            )

        keywords = metadata_tree.findtext('DISS_description/DISS_categorization/DISS_keyword')
        if keywords is not None:
            clean_keywords = keywords.replace(',', ';').replace(':', ';').replace('.', ';')
            record.add_ordered_field(
                pymarc.Field(
                    tag='699',
                    indicators=['0', '4'],
                    subfields=[
                        'a', "{}.".format(clean_keywords)
                    ]
                )
            )

        full_title = metadata_tree.findtext('DISS_description/DISS_title')
        if full_title:
            # Remove " and '
            full_title = full_title.replace('\'', '').replace('"', '')
            if full_title == full_title.upper():
                full_title = full_title.title()

            # Look for leading articles
            indicator2 = '0'
            if full_title.startswith('The '):
                indicator2 = '4'
            elif full_title.startswith('A '):
                indicator2 = '2'
            elif full_title.startswith('An '):
                indicator2 = '3'
            if ':' in full_title:
                split_title = full_title.split(':')
                title = split_title[0]
                subtitle = ':'.join(split_title[1:]).lstrip(' ')
                record.add_ordered_field(
                    pymarc.Field(
                        tag='245',
                        indicators=['1', indicator2],
                        subfields=[
                            'a', title,
                            'h', '[electronic resource]: ',
                            'b', subtitle
                        ]
                    )
                )
            else:
                full_title = full_title.rstrip('.')
                record.add_ordered_field(
                    pymarc.Field(
                        tag='245',
                        indicators=['1', indicator2],
                        subfields=[
                            'a', full_title,
                            'h', '[electronic resource].'
                        ]
                    )
                )

        department = metadata_tree.findtext('DISS_description/DISS_institution/DISS_inst_contact')
        if department:
            record.add_ordered_field(
                pymarc.Field(
                    tag='710',
                    indicators=['2', ' '],
                    subfields=[
                        'a', 'George Washington University.',
                        'b', '{}.'.format(department)
                    ]
                )
            )
        comp_date = metadata_tree.findtext('DISS_description/DISS_dates/DISS_comp_date')
        completion_year = comp_date[0:4] if (comp_date and len(comp_date) >= 4) else None
        if completion_year:
            record.add_ordered_field(
                pymarc.Field(
                    tag='260',
                    indicators=[' ', ' '],
                    subfields=[
                        'a', '[Washington, D. C.] :',
                        'b', 'George Washington University,',
                        'c', '{}.'.format(completion_year)
                    ]
                )
            )

        acc_date = metadata_tree.findtext('DISS_description/DISS_dates/DISS_accept_date')
        accept_date = acc_date[0:10] if (acc_date and len(acc_date) >= 10) else None
        if accept_date:
            record.add_ordered_field(
                pymarc.Field(
                    tag='500',
                    indicators=[' ', ' '],
                    subfields=[
                        'a', 'Title and description based on DISS metadata (ProQuest UMI) as of {}.'.format(accept_date)
                    ]
                )
            )

        degree = metadata_tree.findtext('DISS_description/DISS_degree')
        if degree and completion_year:
            record.add_ordered_field(
                pymarc.Field(
                    tag='502',
                    indicators=[' ', ' '],
                    subfields=[
                        'a', 'Thesis',
                        'b', '({})--'.format(degree),
                        'c', 'George Washington University,',
                        'd', '{}.'.format(completion_year)
                    ]
                )
            )
        lang = metadata_tree.findtext('DISS_description/DISS_categorization/DISS_language')
        if lang and comp_date:
            language = language_map.get(lang[0:2].upper, 'eng')
            record.add_ordered_field(
                pymarc.Field(
                    tag='008',
                    data='{}s{}    dcu     obm   000 0 {} d'.format(running_date, comp_date[0:4], language)
                )
            )

        # Primary authors get added to 100 field else 700 field.
        for author_elem in metadata_tree.findall('DISS_authorship/DISS_author'):
            record.add_ordered_field(
                pymarc.Field(
                    tag='100' if author_elem.attrib.get('type', 'primary') == 'primary' else '700',
                    indicators=['1', ' '],
                    subfields=[
                        'a', self._marc_fullname(author_elem.find('DISS_name'))
                    ]
                )
            )

        # TODO: ISBN
        # marc_out.add("=020  \\\\$a" + cdata);
        return record

    @staticmethod
    def _fullname(name_elem):
        full_name = name_elem.findtext('DISS_surname')
        first_name = name_elem.findtext('DISS_fname')
        middle_name = name_elem.findtext('DISS_middle')
        if first_name:
            full_name = ', '.join([full_name, first_name])
            if middle_name:
                full_name = " ".join([full_name, middle_name])

        return full_name

    @staticmethod
    def _marc_fullname(name_elem):
        full_name = EtdLoader._fullname(name_elem)
        if not full_name.endswith('.'):
            full_name += '.'
        return full_name

    @staticmethod
    def _extract_metadata_file(etd_filepath):
        with zipfile.ZipFile(etd_filepath, 'r') as etd_file:
            for filename in etd_file.namelist():
                if filename.endswith('_DATA.xml'):
                    metadata_filename = filename
                    break
            else:
                raise EtdLoaderException('Metadata file not found in ETD file')

            with etd_file.open(metadata_filename) as metadata_file:
                metadata_tree = ElementTree.parse(metadata_file)
            return metadata_tree

    def _mail_marc_record_file(self):
        # Create the enclosing (outer) message
        outer = MIMEMultipart()
        outer['Subject'] = 'rec load request: gw ETD {}'.format(self.now.strftime('%Y-%m-%d %H:%M:%S'))
        outer['To'] = self.marc_mail_to
        outer['From'] = self.mail_username
        # outer.preamble = 'You will not see this in a MIME-aware mail reader.\n'

        # Add message
        email_body = MIMEText('Attached please find ETD MARC records.', 'plain')
        outer.attach(email_body)

        # Add the attachment to the message
        with open(self.marc_temp_filepath, 'rb') as fp:
            msg = MIMEBase('application', "octet-stream")
            msg.set_payload(fp.read())
        encoders.encode_base64(msg)
        msg.add_header('Content-Disposition', 'attachment', filename=self.marc_record_filename)
        outer.attach(msg)

        # Send the email
        s = smtplib.SMTP(self.mail_host, self.mail_port)
        s.ehlo()
        s.starttls()
        s.ehlo()
        s.login(self.mail_username, self.mail_password)
        s.sendmail(self.mail_username, [self.marc_mail_to], outer.as_string())
        s.close()
        log.info("Sent email to %s with %s attached", self.marc_mail_to, self.marc_record_filename)

    def import_etds(self):
        log.info('Importing ETDs')
        for etd_filename in os.listdir(self.etd_to_be_imported_path):
            etd_id = self._extract_etd_id_from_filename(etd_filename)
            etd_filepath = os.path.join(self.etd_to_be_imported_path, etd_filename)
            # Create temp directory
            etd_temp_path = tempfile.mkdtemp()
            repo_metadata_filepath = os.path.join(etd_temp_path, 'metadata.json')
            try:
                log.info('Importing %s', etd_filename)
                metadata_tree = self._extract_metadata_file(os.path.join(self.etd_to_be_imported_path, etd_filename))
                repo_metadata = self.create_repository_metadata(metadata_tree)
                with open(repo_metadata_filepath, 'w') as repo_metadata_file:
                    json.dump(repo_metadata, repo_metadata_file, indent=4)

                # Unzip
                self.unzip(etd_filepath, etd_temp_path)

                try:
                    binary_filepath, attachment_filepaths = self.find_etd_files(metadata_tree, etd_temp_path)
                except EtdLoaderException as e:
                    log.error("Error importing %s: %s", etd_filename, e)
                    continue

                # Perform the import
                new_etd_id = self.repo_import(repo_metadata_filepath, binary_filepath, attachment_filepaths, etd_id,
                                              self.store.get(etd_id), self.ingest_depositor)
                if not self.dry_run:
                    self.store[etd_id] = new_etd_id
                    # Delete ETD file
                    os.remove(etd_filepath)
            finally:
                if not self.debug_mode:
                    # Delete temporary directory
                    shutil.rmtree(etd_temp_path, ignore_errors=True)

    def create_repository_metadata(self, metadata_tree):
        repository_metadata = {
            # 'title': metadata_tree.find('DISS_description/DISS_title').text
            'creator': [],
            'contributor': [],
            'keyword': [],
            'committee_member': [],
            'advisor': [],
            'gw_affiliation': []
        }

        # creator and contributors
        for author_elem in metadata_tree.findall('DISS_authorship/DISS_author'):
            full_name = self._fullname(author_elem.find('DISS_name'))
            if author_elem.attrib.get('type', 'primary') == 'primary':
                repository_metadata['creator'].append(full_name)
            else:
                repository_metadata['contributor'].append(full_name)

        # date_created
        comp_date = metadata_tree.findtext('DISS_description/DISS_dates/DISS_comp_date')
        completion_year = comp_date[0:4] if (comp_date and len(comp_date) >= 4) else None
        if completion_year:
            repository_metadata['date_created'] = [completion_year]

        # keyword
        keywords = metadata_tree.findtext('DISS_description/DISS_categorization/DISS_keyword')
        if keywords is not None:
            clean_keywords = keywords.replace(',', ';').replace(':', ';')
            for keyword in clean_keywords.split(';'):
                repository_metadata['keyword'].append(keyword.strip())

        # language
        lang = metadata_tree.findtext('DISS_description/DISS_categorization/DISS_language')
        if lang:
            repository_metadata['language'] = [lang]

        # title
        full_title = metadata_tree.findtext('DISS_description/DISS_title')
        if full_title:
            repository_metadata['title'] = [full_title]

        # description
        raw_abstract_text = ""
        for para_elem in metadata_tree.findall('DISS_content/DISS_abstract/DISS_para'):
            raw_abstract_text += para_elem.text
        abstract_text = BeautifulSoup(raw_abstract_text, 'html.parser').text
        if abstract_text:
            repository_metadata['description'] = [abstract_text]

        # gw_affiliation
        department = metadata_tree.findtext('DISS_description/DISS_institution/DISS_inst_contact')
        if department:
            repository_metadata['gw_affiliation'] = [department]

        # embargo date
        embargo_elem = metadata_tree.find('DISS_restriction/DISS_sales_restriction')
        if embargo_elem is not None and 'remove' in embargo_elem.attrib:
            repository_metadata['embargo'] = True
            if embargo_elem.attrib['remove']:
                embargo_date = datetime.strptime(embargo_elem.attrib['remove'], '%m/%d/%Y').date()
                repository_metadata['embargo_release_date'] = embargo_date.isoformat()
            # else the 'remove' element is an empty string, this indicates infinite embargo
            else: 
                repository_metadata['embargo_release_date'] = None

        # degree
        degree = metadata_tree.findtext('DISS_description/DISS_degree')
        if degree:
            repository_metadata['degree'] = [degree]

        # advisors
        for advisor_elem in metadata_tree.findall('DISS_description/DISS_advisor'):
            repository_metadata['advisor'].append(self._fullname(advisor_elem.find('DISS_name')))

        # committee members
        for member_elem in metadata_tree.findall('DISS_description/DISS_cmte_member'):
            repository_metadata['committee_member'].append(self._fullname(member_elem.find('DISS_name')))


        return repository_metadata

    @staticmethod
    def find_etd_files(metadata_tree, etd_temp_path):
        binary_filename = metadata_tree.find('DISS_content/DISS_binary').text
        binary_filepath = os.path.join(etd_temp_path, binary_filename)
        if not os.path.exists(binary_filepath):
            raise EtdLoaderException('{} is missing'.format(binary_filename))

        file_map = {}
        for root, dirnames, filenames in os.walk(etd_temp_path):
            for filename in filenames:
                file_map[filename] = os.path.join(root, filename)

        attachment_filepaths = []
        for attachment_filename in [elem.text for elem in
                                    metadata_tree.findall('DISS_content/DISS_attachment/DISS_file_name')]:
            if attachment_filename in file_map:
                attachment_filepaths.append(file_map[attachment_filename])
            else:
                raise EtdLoaderException('{} is missing'.format(attachment_filename))

        return binary_filepath, attachment_filepaths

    def repo_import(self, repo_metadata_filepath, etd_filepath, attachment_filepaths, etd_id, repository_id, depositor):
        log.info('Importing %s. ETD file is %s and attachements are %s', etd_id, etd_filepath, attachment_filepaths)
        # rake gwss:ingest_etd -- --manifest='path-to-manifest-json-file' --primaryfile='path-to-primary-attachment-file/myfile.pdf' --otherfiles='path-to-all-other-attachments-folder'
        command = self.ingest_command.split(' ') + ['--',
                                                    '--manifest=%s' % repo_metadata_filepath,
                                                    '--primaryfile=%s' % etd_filepath,
                                                    '--depositor=%s' % depositor]
        if attachment_filepaths:
            command.extend(['--otherfiles=%s' % ','.join(attachment_filepaths)])
        if repository_id:
            log.info('%s is an update.', etd_id)
            command.extend(['--update-item-id=%s' % repository_id])
        log.info("Command is: %s" % ' '.join(command))
        if not self.dry_run:
            output = subprocess.check_output(command, cwd=self.ingest_path)
            repository_id = output.decode('utf-8').rstrip('\n')
            log.info('Repository id for %s is %s', etd_id, repository_id)
            return repository_id
        else:
            return "dummy_repository_id"

    @staticmethod
    def unzip(zip_filepath, dest_path):
        log.info("Unzipping %s to %s", zip_filepath, dest_path)
        with zipfile.ZipFile(zip_filepath, 'r') as zip_file:
            zip_file.extractall(path=dest_path)

    @staticmethod
    def _extract_etd_id_from_filename(filename):
        # Format is etdadmin_upload_<ETD ID>.zip
        return filename[16:-4]


class IdStore:
    def __init__(self, base_path="."):
        self.db_filepath = os.path.join(base_path, 'id.db')
        log.debug('Db filepath is %s', self.db_filepath)
        create_db = not os.path.exists(self.db_filepath)
        self._conn = sqlite3.connect(self.db_filepath)
        if create_db:
            self._create_db()

    def _create_db(self):
        logging.info("Creating db")
        c = self._conn.cursor()

        # Creating a new table
        c.execute("""
            CREATE TABLE ids (etd_id PRIMARY KEY, repository_id);
        """)

        self._conn.commit()

    def __contains__(self, etd_id):
        """
        Returns True if there is a record for the etd id.
        """
        c = self._conn.cursor()
        c.execute("""
                SELECT etd_id FROM ids WHERE etd_id=?;
            """, (etd_id,))
        if c.fetchone():
            return True
        return False

    def get(self, etd_id):
        try:
            return self.__getitem__(etd_id)
        except IndexError:
            return None

    def __getitem__(self, etd_id):
        """
        Returns repository_id for etd_id.
        """
        c = self._conn.cursor()
        c.execute("""
            SELECT repository_id FROM ids WHERE etd_id=?;
        """, (etd_id,))
        row = c.fetchone()
        if not row:
            raise IndexError
        return row[0]

    def __setitem__(self, etd_id, repository_id):
        """
        Adds repository_id or updates existing repository_id.
        """
        c = self._conn.cursor()

        if etd_id in self:
            # Make update
            log.info("Updating %s to %s", etd_id, repository_id)
            c.execute("""
                UPDATE ids SET repository_id=? WHERE etd_id=?
            """, (repository_id, etd_id))
        else:
            # Add
            log.info("Adding %s with %s", etd_id, repository_id)
            c.execute("""
                INSERT INTO ids (etd_id, repository_id)
                VALUES (?, ?)
            """, (etd_id, repository_id))

        self._conn.commit()

    def __iter__(self):
        c = self._conn.cursor()
        c.execute("""
            SELECT etd_id, repository_id FROM ids
        """)

        return iter(c.fetchall())

    # Methods to make this a Context Manager. This is necessary to make sure the connection is closed properly.
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self._conn.close()


def prettify(elem):
    """Return a pretty-printed XML string for the Element.
    """
    rough_string = ElementTree.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ", newl='\r')


class EtdLoaderException(Exception):
    pass


if __name__ == '__main__':
    import config

    parser = argparse.ArgumentParser(description='Loads Proquest ETDs into GW Scholarspace and creates MARC records')
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--only', help='Perform only this step', choices=['retrieve', 'import', 'marc'])

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.debug else logging.INFO
    )
    logging.basicConfig(level=logging.DEBUG)

    l = EtdLoader(config.base_path, config.etd_ftp_host, config.etd_ftp_username, config.etd_ftp_password,
                  config.etd_ftp_path, config.etd_ftp_port, config.mail_host, config.mail_username,
                  config.mail_password, config.mail_port, config.marc_mail_to, config.ingest_path,
                  config.ingest_command, config.ingest_depositor, config.repo_base_url, config.debug_mode,
                  config.dry_run)
    if args.only == 'retrieve':
        l.retrieve_etd_files()
    elif args.only == 'marc':
        l.create_marc_records()
    elif args.only == 'import':
        l.import_etds()
    else:
        l.retrieve_etd_files()
        l.import_etds()
        l.create_marc_records()
