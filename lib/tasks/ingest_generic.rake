# frozen_string_literal: true
require 'fileutils'
require 'json'
require 'optparse'
# copied from https://github.com/gwu-libraries/ and heavily modified
namespace :wpi do
  # adding a logger since it got removed from our gemset
  # def logger
  #  Rails.logger
  # end
  class InvalidWorkType < StandardError
  end
  desc "Queues a job to (re)generate the sitemap.xml"
  task "sitemap_queue_generate" => :environment do
    SitemapRegenerateJob.perform_later
  end

  desc "Create digitalwpi user roles"
  task create_roles: :environment do
    adminrole = Role.find_or_create_by(name: 'admin')
    adminrole.save

    contentadminrole = Role.find_or_create_by(name: 'content-admin')
    contentadminrole.save
  end

  desc "Ingest a Work"
  task ingest_work: :environment do |_t, args|
    options = {}

    op = OptionParser.new
    op.banner = "Usage: rake ingest -- --manifest=MFPATH --primaryfile=PFPATH --otherfiles=OFLIST --depositor=DEPOSITOR --update-item-id=UPDATEID --worktype WORKTYPE --collection=COLLECTION (optional)"
    op.on('-mf MFPATH', '--manifest=MFPATH', 'Path to manifest file') { |mfpath| options[:mfpath] = mfpath }
    op.on('-pf FPATH', '--primaryfile=PFPATH', 'Path to primary attachment file') { |pfpath| options[:pfpath] = pfpath }
    op.on('-of OFLIST', '--otherfiles=OFLIST', 'Deliniated list of paths to supplemental files,Delimiter={|,|}') { |oflist| options[:oflist] = oflist }
    op.on('-dep DEPOSITOR', '--depositor=DEPOSITOR', 'Scholarspace ID (e.g. email) of depositor') { |depositor| options[:depositor] = depositor }
    op.on('--set-item-id[=UPDATEID]', 'Set Item ID') { |setid| options[:setid] = setid }
    op.on('--update-item-id[=UPDATEID]', 'Update Item ID') { |updateid| options[:updateid] = updateid }
    op.on('-wt WORKTYPE', '--worktype=WORKTYPE', 'string representing hyrax worktype, ie worktype') { |worktype| options[:worktype] = worktype }
    op.on('-cl COLLECTION', '--collection=COLLECTION', 'an id of a collection to add these works to') { |collectionid| options[:collectionid] = collectionid }
    op.on('--private', 'Ingest and create with Private visibility') do
      options[:private] = true
    end

    # return `ARGV` with the intended arguments
    args = op.order!(ARGV) {}
    op.parse!(args)

    raise OptionParser::MissingArgument if options[:mfpath].nil?
    raise OptionParser::MissingArgument if options[:pfpath].nil?
    raise OptionParser::MissingArgument if options[:depositor].nil?
    raise OptionParser::MissingArgument if options[:worktype].nil?
    begin
      worktype = eval(options[:worktype])
    rescue
      raise InvalidWorkType, "An invalid worktype was given #{options[:worktype]} was not okay"
    end

    manifest_file = options[:mfpath]
    if File.exist?(manifest_file)
      mf = File.read(manifest_file)
      manifest_json = JSON.parse(mf.squish)
      item_attributes = manifest_json.dup
      item_attributes.delete('embargo')
      item_attributes.delete('embargo_visibility')
      item_attributes.delete('embargo_release_date')

      # dc:rights
      # There are some items with extraneous 'None' values; remove these
      licenses = (manifest_json['license'] || []) - ['None']
      item_attributes['license'] = if licenses.empty?
                                     ['http://www.europeana.eu/portal/rights/rr-r.html']
                                   else
                                     licenses
                                   end

      # edm:rights
      item_attributes['rights_statement'] = ['http://rightsstatements.org/vocab/InC/1.0/']

      work_id = ingest_work(item_attributes, options[:depositor], options[:updateid], options[:setid], options[:private], worktype)
      # generate_ingest_report(noid_list, investigation_id)
      embargo_attributes = read_embargo_info(manifest_json)

      gww = worktype.find(work_id)
      attach_files(gww, options[:pfpath], options[:oflist],
                   options[:depositor], embargo_attributes)
      if options[:collectionid]
        col = Collection.find(options[:collectionid]) # throws error if id not found
        gww.member_of_collections << col
        gww.save
      end
      puts work_id
    else
      puts "Manifest file doesn't exist - no ingest"
    end
  end

  task ingest_work_res_to_collections: :environment do |_t, args|
    options = {}

    op = OptionParser.new
    op.banner = "Usage: rake ingest -- --manifest=MFPATH --primaryfile=PFPATH --otherfiles=OFLIST --depositor=DEPOSITOR --update-item-id=UPDATEID"
    op.on('-mf MFPATH', '--manifest=MFPATH', 'Path to manifest file') { |mfpath| options[:mfpath] = mfpath }
    op.on('-pf FPATH', '--primaryfile=PFPATH', 'Path to primary attachment file') { |pfpath| options[:pfpath] = pfpath }
    op.on('-of OFLIST', '--otherfiles=OFLIST', 'Deliniated list of paths to supplemental files,Delimiter={|,|}') { |oflist| options[:oflist] = oflist }
    op.on('-dep DEPOSITOR', '--depositor=DEPOSITOR', 'Scholarspace ID (e.g. email) of depositor') { |depositor| options[:depositor] = depositor }
    op.on('--set-item-id[=UPDATEID]', 'Set Item ID') { |setid| options[:setid] = setid }
    op.on('--update-item-id[=UPDATEID]', 'Update Item ID') { |updateid| options[:updateid] = updateid }
    op.on('-wt WORKTYPE', '--worktype=WORKTYPE', 'string representing hyrax worktype, ie worktype') { |worktype| options[:worktype] = worktype }
    op.on('--private', 'Ingest and create with Private visibility') do
      options[:private] = true
    end

    # return `ARGV` with the intended arguments
    args = op.order!(ARGV) {}
    op.parse!(args)

    raise OptionParser::MissingArgument if options[:mfpath].nil?
    raise OptionParser::MissingArgument if options[:pfpath].nil?
    raise OptionParser::MissingArgument if options[:depositor].nil?
    raise OptionParser::MissingArgument if options[:worktype].nil?
    begin
      worktype = eval(options[:worktype])
    rescue
      raise InvalidWorkType, "An invalid worktype was given #{options[:worktype]} was not okay"
    end
    manifest_file = options[:mfpath]
    if File.exist?(manifest_file)
      mf = File.read(manifest_file)
      manifest_json = JSON.parse(mf.squish)
      item_attributes = manifest_json.dup
      item_attributes.delete('embargo')
      item_attributes.delete('embargo_release_date')

      # dc:rights
      # There are some items with extraneous 'None' values; remove these
      licenses = (manifest_json['license'] || []) - ['None']
      item_attributes['license'] = if licenses.empty?
                                     ['http://www.europeana.eu/portal/rights/rr-r.html']
                                   else
                                     licenses
                                   end

      # edm:rights
      item_attributes['rights_statement'] = ['http://rightsstatements.org/vocab/InC/1.0/']

      work_id = ingest_work(item_attributes, options[:depositor], options[:updateid], options[:setid], options[:private], worktype)
      # generate_ingest_report(noid_list, investigation_id)
      embargo_attributes = read_embargo_info(manifest_json)

      gww = worktype.find(work_id)
      attach_files(gww, options[:pfpath], options[:oflist],
                   options[:depositor], embargo_attributes)
      for res_type in gww.resource_type do
        collections = Collection.where(title: res_type)
        if collections.length == 1
          gww.member_of_collections << collections[0]
          gww.save
        end
      end

      puts work_id
    else
      puts "Manifest file doesn't exist - no ingest"
    end
  end

  desc "Ingest an ETD"
  task ingest_etd: :environment do |_t, args|
    options = {}

    op = OptionParser.new
    op.banner = "Usage: rake gwss:ingest_etd -- --manifest=MFPATH --primaryfile=PFPATH --otherfiles=OFLIST --depositor=DEPOSITOR --update-item-id=UPDATEID"
    op.on('-mf MFPATH', '--manifest=MFPATH', 'Path to manifest file') { |mfpath| options[:mfpath] = mfpath }
    op.on('-pf FPATH', '--primaryfile=PFPATH', 'Path to primary attachment file') { |pfpath| options[:pfpath] = pfpath }
    op.on('-of OFLIST', '--otherfiles=OFLIST', 'Deliniated list of paths to supplemental files,Delimiter={|,|}') { |oflist| options[:oflist] = oflist }
    op.on('-dep DEPOSITOR', '--depositor=DEPOSITOR', 'Scholarspace ID (e.g. email) of depositor') { |depositor| options[:depositor] = depositor }
    op.on('-wt WORKTYPE', '--worktype=WORKTYPE', 'string representing hyrax worktype, ie worktype') { |worktype| options[:worktype] = worktype }
    op.on('--update-item-id[=UPDATEID]', 'Update Item ID') { |updateid| options[:updateid] = updateid }

    # return `ARGV` with the intended arguments
    args = op.order!(ARGV) {}
    op.parse!(args)

    raise OptionParser::MissingArgument if options[:mfpath].nil?
    raise OptionParser::MissingArgument if options[:pfpath].nil?
    raise OptionParser::MissingArgument if options[:depositor].nil?
    raise OptionParser::MissingArgument if options[:worktype].nil?

    # Reference worktype to work around circular dependency
    # problem that would be caused by referencing worktype first
    # See articles such as http://neethack.com/2015/04/rails-circular-dependency/
    worktype = eval(options[:worktype])

    manifest_file = options[:mfpath]
    if File.exist?(manifest_file)
      mf = File.read(manifest_file)
      manifest_json = JSON.parse(mf.squish)
      item_attributes = manifest_json.dup
      # Since we're going to embargo the file, not the item:
      item_attributes.delete('embargo')
      item_attributes.delete('embargo_release_date')
      item_attributes['degree'] = manifest_json['degree'][0] if manifest_json['degree']
      # resource_type may need more logic around it, TBD
      item_attributes['resource_type'] = ['Thesis or Dissertation']

      # dc:rights
      item_attributes['license'] = ['http://www.europeana.eu/portal/rights/rr-r.html']
      item_attributes.delete('rights')

      # edm:rights
      item_attributes['rights_statement'] = ['http://rightsstatements.org/vocab/InC/1.0/']

      etd_id = ingest_etd(item_attributes, options[:depositor], options[:updateid], worktype)
      # generate_ingest_report(noid_list, investigation_id)
      embargo_attributes = read_embargo_info(manifest_json)
      gwe = worktype.find(etd_id)
      attach_files(gwe, options[:pfpath], options[:oflist],
                   options[:depositor], embargo_attributes)
      puts etd_id
    else
      puts "Manifest file doesn't exist - no ingest"
    end
  end

  def ingest_work(item_attributes, depositor, updateid, setid, visibility_private, worktype)
    gww = nil
    if updateid.nil?
      gww = worktype.new
      gww.id = if setid.nil?
                 ActiveFedora::Noid::Service.new.mint
               else
                 setid
               end
    else
      gww = worktype.find(updateid)
      # delete existing files; we'll "overwrite" with new ones
      # TODO: Unfortunately, this will have the effect that links
      # to individual files won't be persistent if the ETD is updated
      # To solve this, we'd need a scheme for matching up updated files
      # with existing files (perhaps by file name?)
      fsets = gww.file_sets
      fsets.each(&:delete)
    end

    gww.apply_depositor_metadata(depositor)
    # set the attributes of the work
    # File.open('log.txt', 'w') { |file| file.write(item_attributes.inspect) }


    gww.attributes = item_attributes
    gww.visibility = if visibility_private
                       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
                     else
                       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
                     end
    now = Hyrax::TimeService.time_in_utc
    gww.date_uploaded = now

    # Add to Default Administrative Set
    default_admin_set_id = AdminSet.find_or_create_default_admin_set_id
    default_admin_set = AdminSet.find(default_admin_set_id)
    gww.admin_set = default_admin_set
    gww.set_edit_groups(["content-admin"], [])
    gww.save

    gww.id
  end

  def ingest_etd(item_attributes, depositor, updateid, worktype)
    gwe = nil
    if updateid.nil?
      gwe = worktype.new
      gwe.id = ActiveFedora::Noid::Service.new.mint
    else
      gwe = worktype.find(updateid)
      # delete existing files; we'll "overwrite" with new ones
      # TODO: Unfortunately, this will have the effect that links
      # to individual files won't be persistent if the ETD is updated
      # To solve this, we'd need a scheme for matching up updated files
      # with existing files (perhaps by file name?)
      fsets = gwe.file_sets
      fsets.each(&:delete)
    end

    gwe.apply_depositor_metadata(depositor)
    gwe.attributes = item_attributes
    gwe.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    now = Hyrax::TimeService.time_in_utc
    gwe.date_uploaded = now

    etd_admin_set = AdminSet.where(title: "ETDs")[0]
    gwe.admin_set = etd_admin_set
    gwe.set_edit_groups(["content-admin"], [])
    gwe.save
    gwe.id
  end

  def read_embargo_info(metadata)
    embargo_info = {}
    embargo_info['embargo'] = metadata['embargo'] == true ? true : false
    if embargo_info['embargo'] == true
      embargo_info['embargo_release_date'] = metadata['embargo_release_date'].nil? ? '2100-01-01' : metadata['embargo_release_date']
      visibilities = []
      metadata['embargo_visibility'].each do |item| 
        if item == "public"
          visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        elsif item == "authenticated"
          visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        else
          visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        end
      end
      embargo_info['embargo_visibility'] = visibilities

      if embargo_info['embargo_visibility'].length != 2
        puts embargo_info['embargo_visibility']
        raise "not the correct amount of visibilities were sent. got: #{embargo_visibility}"
      end
    end

    return embargo_info
  end

  def attach_files(work, primaryfile_path, otherfiles_list, depositor, embargo_attributes)
    user = User.find_by_user_key(depositor)
    # add primary file first, other files afterwards
    files = []
    files += [primaryfile_path] if primaryfile_path
    files += otherfiles_list.split('{|,|}') if otherfiles_list
    files.each do |f|
      fs = FileSet.new
      # use the filename as the FileSet title
      fs.id = ActiveFedora::Noid::Service.new.mint
      fs.title = [File.basename(f)]
      actor = ::Hyrax::Actors::FileSetActor.new(fs, user)
      actor.create_metadata
      actor.create_content(File.open(f))
      actor.attach_to_work(work)
      if embargo_attributes['embargo'] == true
        fs.apply_embargo(embargo_attributes['embargo_release_date'],
                         embargo_attributes['embargo_visibility'][0],
                         embargo_attributes['embargo_visibility'][1])
      end
      fs.set_edit_groups(["content-admin"], [])
      fs.save
    end
  end

  desc "Reindex everything"
  task reindex_everything: :environment do
    ActiveFedora::Base.reindex_everything
  end
end
