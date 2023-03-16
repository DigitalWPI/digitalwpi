require 'json'
class ReindexWithLogs

  def initialize(log_file_path)
    @og_file_path = log_file_path
  end

  def my_logger
    @my_logger ||= Logger.new(@og_file_path)
  end

  def reindex_everything(from, dir_path: nil, files_to_process: [], uri: nil, batch_size: 50, softCommit: true, progress_bar: false, final_commit: true, dry_run: false)
    """
    based on https://github.com/samvera/active_fedora/blob/v13.2.5/lib/active_fedora/indexing.rb#L98
    from: How do you want to reindex?
    active_fedora_base: All records in Fedora, starting from the base URI
    solr_results: The ids od the docs will be retrieved from solr response(s) and indexed.
                  Needs dir_path, containing one or more json file containing a solr response.
    uri: The fedora uri to index (and all it's descendants)
    file: A directory containing one or more json files. Each file has an array of descendant URIs
    """
    my_logger.info "Re-index everything ... #{from}"

    descendants = gather_descendants(from, dir_path: dir_path, files_to_process: files_to_process, uri: uri)
    batch_count = 1
    batch = []

    progress_bar_controller = ProgressBar.create(total: descendants.count, format: "%t: |%B| %p%% %e") if progress_bar

    descendants.each do |uri|

      begin
        my_logger.debug "Gathering solr doc for #{uri}"
        doc = ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(uri)).to_solr
        batch << doc if doc
      rescue => e
        my_logger.error "Error gathering solr doc for #{uri}"
        my_logger.error e.message
        my_logger.error e.backtrace.join("\n")
      end

      if (batch.count % batch_size).zero?
        my_logger.info "Soft committing batch #{batch_count}"
        ActiveFedora::SolrService.add(batch, softCommit: softCommit) unless dry_run
        batch.clear
        batch_count += 1
      end

      progress_bar_controller&.increment if progress_bar
    end

    if batch.present?
      my_logger.info "Soft committing last batch #{batch_count}"
      ActiveFedora::SolrService.add(batch, softCommit: softCommit) unless dry_run
      batch.clear
    end
    return unless dry_run
    return unless final_commit

    my_logger.info "Solr hard commit..."
    ActiveFedora::SolrService.commit
  end

  def gather_descendants(from, dir_path: nil, files_to_process: [], uri: nil)
    case from
    when 'active_fedora_base'
      my_logger.info "Gathering all descendants from active fedora base... #{ActiveFedora.fedora.base_uri}"
      # skip root url
      descendants = descendant_uris(ActiveFedora.fedora.base_uri, exclude_uri: true)
      log_descendants(descendants, file_prefix: 'active_fedora_base_uri')
    when 'solr_results'
      my_logger.info "Gathering all descendants from solr document results... #{dir_path}"
      descendants = get_descendants_from_solr(dir_path, files_to_process)
    when 'uri'
      my_logger.info "Gathering all descendants for uri... #{uri}"
      descendants = descendant_uris(uri, exclude_uri: false)
    when 'file'
      descendants = get_descendants_from_file(dir_path, files_to_process)
    else
      my_logger.info "No descendants to gather. Choices are: active_fedora_base, solr_results, uri"
      descendants = []
    end
    descendants
  end

  def get_descendants_from_solr(dir_path, files_to_process)
    files_to_process = Dir.entries(File.join(dir_path, '*.json')) unless files_to_process
    # uris = []
    descendants = []
    files_to_process.each do |filename|
      my_logger.debug "Gathering ids from json file #{filename}"
      file_uris = get_uris_from_doc_ids(dir_path, filename)
      file_descendants = []
      file_uris.each do |uri|
        file_descendants += descendant_uris(uri)
        log_descendants(file_descendants, File.basename(filename,File.extname(filename)))
      end
      descendants += file_descendants
    end
    descendants
  end

  def get_descendants_from_file(dir_path, files_to_process)
    files_to_process = Dir.entries(File.join(dir_path, '*.json')) unless files_to_process
    descendants = []
    files_to_process.each do |filename|
      my_logger.debug "Gathering descendant URIs from json file #{filename}"
      file_descendants = read_descendant_uris_from_file(dir_path, filename)
      descendants += file_descendants
    end
    descendants
  end

  def descendant_uris(uri, exclude_uri: false)
    begin
      uris = ActiveFedora::Indexing::DescendantFetcher.new(uri, exclude_self: exclude_uri).descendant_and_self_uris
    rescue => e
      uris = []
      my_logger.error "Error gathering descendant for #{uri}"
      my_logger.error e.message
      my_logger.error e.backtrace.join("\n")
    end
    uris
  end

  def descendant_uris_by_model(uri, exclude_uri: false)
    begin
      uris = ActiveFedora::Indexing::DescendantFetcher.new(Auri, exclude_self: exclude_uri).descendant_and_self_uris_partitioned_by_model
    rescue => e
      uris = []
      my_logger.error "Error gathering descendant for #{uri}"
      my_logger.error e.message
      my_logger.error e.backtrace.join("\n")
    end
    uris
  end

  def get_uris_from_solr(dir_path, files_to_process)
    files_to_process = Dir.entries(File.join(dir_path, '*.json')) unless files_to_process
    # files_to_process = %w(Collection_ids.json Etd_ids.json GenericWork_ids.json student_work_ids.json FileSet_ids.json)
    uris = []
    files_to_process.each do |filename|
      my_logger.debug "Gathering ids from json file #{filename}"
      uris += get_uris_from_doc_ids(dir_path, filename)
    end
    uris
  end

  private

  def get_uris_from_doc_ids(dir_path, filename)
    filepath = File.join(dir_path, filename)
    uris = []
    return uris unless File.exists?(filepath)
    file = File.read(filepath)
    solr_response = JSON.parse(file)
    solr_response['response']['docs'].each do |doc|
      uri = id_to_uri(doc['id'])
      uris << uri if uri
    end
    uris
  end

  def id_to_uri(id)
    case id.size
    when proc { |n| n > 7 }
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/#{id[6..7]}/#{id}"
    when 7
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/#{id[6]}/#{id}"
    when 6
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/#{id}"
    when 5
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0..1]}/#{id[2..3]}/#{id[4]}/#{id}"
    when 4
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0..1]}/#{id[2..3]}/#{id}"
    when 3
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0..1]}/#{id[2]}/#{id}"
    when 2
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0..1]}/#{id}"
    when 1
      uri = "#{ActiveFedora.fedora.base_uri}/#{id[0]}/#{id}"
    else
      uri = nil
    end
    uri
  end

  def read_descendant_uris_from_file(dir_path, filename)
    filepath = File.join(dir_path, filename)
    uris = []
    return uris unless File.exists?(filepath)
    file = File.read(filepath)
    uris = JSON.parse(file)
    uris
  end

  def log_descendants(descendants, file_prefix='')
    file_prefix = "#{file_prefix}_" if file_prefix
    file_dir = File.dirname(@og_file_path)
    descendant_log_file = File.join(file_dir, "#{file_prefix}descendants.log")
    File.write(descendant_log_file, JSON.pretty_generate(descendants))
  end
end

# -----------------------------------------
# usage - reindex starting from active fedora base
# -----------------------------------------
# r = ReindexWithLogs.new('/home/webapp/reindex_work/reindex.log')
# from = 'active_fedora_base'
# r.reindex_everything(from)

# If you do not want to reindex, but want to gather all the URIs and solr documents which are going to be indexed, run the following
# r = ReindexWithLogs.new('/home/webapp/reindex_work/reindex.log')
# from = 'active_fedora_base'
# r.gather_descendants(from, dry_run: true)

# If you do not want to reindex, but want to gather all the URIs which are going to be indexed, run the following
# r = ReindexWithLogs.new('/home/webapp/reindex_work/reindex.log')
# from = 'active_fedora_base'
# r.gather_descendants(from)

# Gathering all descendants can take a couple of hours, for a Hyrax instance with 15 collections and 3000 works

# -----------------------------------------
# usage - reindex with solr response data
# -----------------------------------------
# This will extract the ids of the documents from the solr response and reindex them
# r = ReindexWithLogs.new('/home/webapp/reindex_work/reindex.log')
# from = 'solr_results'
# dir_path = "/home/webapp/reindex_work/ids_to_index"
# files_to_process = ['Collection_ids.json', 'Datasets.json']
# ---- if files_to_process is empty, all files in the directory dir_path will be processed
# r.reindex_everything(from, dir_path: dir_path, files_to_process: files_to_process)

# -----------------------------------------
# usage - reindex with uri
# -----------------------------------------
# r = ReindexWithLogs.new('/home/webapp/reindex_work/reindex.log')
# from = 'uri'
# uri should be a fedora uri
# uri = "http://localhost:8080/fcrepo/rest/prod/70/79/5b/48/70795b489"
# r.reindex_everything(from, uri: uri)

# -----------------------------------------
# usage - gather descendants and reindex with descendant uris written to file
# -----------------------------------------
# This will need the descendant URIs to have been fetched, either using doc ids from solr or from active fedora base
# r = ReindexWithLogs.new('/home/webapp/reindex_work/reindex.log')
# r.gather_descendants('active_fedora_base')
# from = 'file'
# dir_path = "/home/webapp/reindex_work/descendants/"
# files_to_process = ['Collection_ids_descendants.log', 'Dataset_ids_descendants.log']
# ---- if files_to_process is empty, all files in the directory dir_path will be processed
# r.reindex_everything(from, dir_path: dir_path, files_to_process: files_to_process)

