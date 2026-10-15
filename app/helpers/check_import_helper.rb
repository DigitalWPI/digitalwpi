require 'fileutils'
include ImportHelper

module CheckImportHelper
  def check_roles(base_dir)
    model_dir = Rails.root.join(base_dir, "Role")
    has_role = []
    role_missing = []
    @base_dir = base_dir
    @collection_ids = get_collection_id_mappings
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      metadata = parse_metadata_file(file_path)
      r = Role.find_by(name: metadata['name'])
      if r
        has_role.append(file_path)
      else
        role_missing.append(file_path)
      end
    end
    puts "Number of roles created: #{has_role.size}"
    puts "Number of roles missing: #{role_missing.size}"
    {'has_role' => has_role, 'role_missing' => role_missing}
  end

  def check_users(base_dir)
    model_dir = Rails.root.join(base_dir, "User")
    has_user = []
    user_missing = []
    email_missing = []
    @base_dir = base_dir
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      user_hash = parse_metadata_file(file_path)
      if user_hash.fetch('email', nil).present?
        user = User.find_by(email: user_hash['email'])
        if user
          has_user.append(file_path)
        else
          user_missing.append(file_path)
        end
      else
        email_missing.append(file_path)
      end
    end
    puts "Number of users created: #{has_user.size}"
    puts "Number of users missing: #{user_missing.size}"
    puts "Number of users with no email id: #{email_missing.size}"
    {'has_user' => has_user, 'user_missing' => user_missing, 'email_missing' => email_missing}
  end

  def check_users_in_roles(base_dir)
    role_model_dir = Rails.root.join(base_dir, "Role")
    role_missing = []
    has_all_users_in_role = []
    users_in_role_error = {}
    @base_dir = base_dir
    @collection_ids = get_collection_id_mappings
    Dir.glob(Rails.root.join(role_model_dir, '*', '*')).each do |file_path|
      metadata = parse_metadata_file(file_path)
      role = Role.find_by(name: metadata['name'])
      if role.present?
        role_users = role.users.collect{|u| u[:email]}
        if role_users.to_set == metadata['users'].to_set
          has_all_users_in_role.append(file_path)
        else
          users_in_role_error[metadata['name']] = {'file_path' => file_path, 'users_missing' => []}
          metadata['users'].each do |u|
            users_in_role_error[metadata['name']]['users_missing'].append(u)
            puts "User #{u} not in role #{metadata['name']}" unless role_users.include?(u)
          end
        end
      else
        role_missing.append(file_path)
      end
    end
    puts "Number of roles with all users: #{has_all_users_in_role.size}"
    puts "Number of roles missing: #{role_missing.size}"
    puts "Number of roles where users don't match: #{users_in_role_error.size}"
    {'role_missing' => role_missing,
     'users_in_role_error' => users_in_role_error,
     'has_all_users_in_role' => has_all_users_in_role}
  end

  def create_missing_roles(base_dir)
    model_dir = Rails.root.join(base_dir, "Role")
    reimport_roles = []
    @base_dir = base_dir
    @collection_ids = get_collection_id_mappings
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      metadata = parse_metadata_file(file_path)
      role_name = parse_roles(Array(metadata['name']), comma_separated: false)
      metadata['name'] = role_name.first if role_name.present? and role_name.first.present?
      r = Role.find_by(name: metadata['name'])
      unless r.present?
        reimport_roles.append(file_path)
        ImportRoleJob.perform_later(file_path, @base_dir, @collection_ids)
      end
    end
    puts "Number of roles re-imported: #{reimport_roles.size}"
    reimport_roles
  end

  def create_missing_users(base_dir)
    model_dir = Rails.root.join(base_dir, "User")
    reimport_users = []
    @base_dir = base_dir
    @collection_ids = get_collection_id_mappings
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      metadata = parse_metadata_file(file_path)
      u = User.find_by(name: metadata['email'])
      if not u
        reimport_users.append(file_path)
        ImportUserJob.perform_later(file_path, @base_dir, @collection_ids)
      end
    end
    puts "Count of users re-imported: #{reimport_users.size}"
    reimport_users
  end

  def fix_users_in_roles(base_dir)
    @base_dir = base_dir
    model_dir = Rails.root.join(base_dir, "Role")
    @collection_ids = get_collection_id_mappings
    role_missing = []
    users_in_role_error = {}
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      metadata = parse_metadata_file(file_path)
      role = Role.find_by(name: metadata['name'])
      if not role
        role_missing.append(file_path)
      else
        role_users = role.users.collect{|u| u[:email]}
        unless role_users.to_set == metadata['users'].to_set
          users_in_role_error[metadata['name']] = {'file_path' => file_path, 'users_missing' => []}
          metadata['users'].each do |u|
            users_in_role_error[metadata['name']]['users_missing'].append(u)
            puts "User #{u} not in role #{metadata['name']}" unless role_users.include?(u)
          end
        end
      end
    end
    error = []
    users_added_to_role = []
    users_in_role_error.each do |k, v|
      role = Role.find_by(name: k)
      v['users_missing'].each do |u|
        user = User.find_by(email: u)
        if user.present?
          role.users << user
          role.save!
          sleep(1)
          users_added_to_role.append("#{user.id} added to #{k}, id:#{role.id}")
        else
          error.append("Did not find user #{u} for role #{k}, id:#{role.id}")
        end
      end
    end
    puts "Number of users added to roles: #{users_added_to_role.size}"
    puts "Number of user accounts not found: #{error.size}"
    {'users_added_to_role' => users_added_to_role,
     'User account missing' => error
    }
  end

  def check_collections(base_dir)
    model_dir = Rails.root.join(base_dir, "Collection")
    has_collection = []
    collection_missing = []
    wrong_type = []
    id_missing = []
    wrong_parent = []
    @base_dir = base_dir
    @collection_ids = get_collection_id_mappings
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      collection_hash = parse_metadata_file(file_path)
      id =  @collection_ids.fetch(collection_hash["id"], nil)
      if id.present?
        col = Collection.find_by(id: id)
        if col.present?
          has_collection.append("#{collection_hash["title_tesim"]}, #{file_path}")
          # Collection type
          # typ = collection_hash.fetch("collection_type_gid_ssim", [])
          # if Array(col.collection_type_gid).to_set != typ.to_set
          #   wrong_type.append("#{collection_hash["title_tesim"]}, old: #{typ}, new: #{col.collection_type_gid}")
          # end
          # Collection parent
          if collection_hash.fetch("nesting_collection__parent_ids_ssim", []).present? || col.member_of_collection_ids.present?
            parent_ids_in_file = collection_hash.fetch("nesting_collection__parent_ids_ssim", []).map { |old_id| @collection_ids.fetch(old_id, nil) }
            parent_ids = col.member_of_collection_ids&.map { |id| id.to_s }
            if Array(parent_ids).to_set != parent_ids_in_file.to_set
              wrong_parent.append("#{collection_hash["title_tesim"]}, old: #{parent_ids_in_file}, new: #{col.member_of_collection_ids}")
            end
          end
        else
          collection_missing.append("#{collection_hash["title_tesim"]}, #{file_path}")
        end
      else
        id_missing.append(file_path)
      end
    end
    puts "Number of collections created: #{has_collection.size}"
    puts "Number of collections missing: #{collection_missing.size}"
    puts "Number of collections with no mapped id: #{id_missing.size}"
    puts "Number of collections with wrong type: #{wrong_type.size}"
    puts "Number of collections with wrong parent: #{wrong_parent.size}"
    {
      'has_collection' => has_collection,
      'collection_missing' => collection_missing,
      'id_missing' => id_missing,
      'wrong_type' => wrong_type,
      'wrong_parent' => wrong_parent,
    }
  end

  def create_missing_collections(base_dir)
    model_dir = Rails.root.join(base_dir, "Collection")
    collections_created = []
    @base_dir = base_dir
    @collection_ids = get_collection_id_mappings
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      collection_hash = parse_metadata_file(file_path)
      id =  @collection_ids.fetch(collection_hash["id"], nil)
      if id.present?
        col = Collection.find_by(id: id)
        unless col.present?
          collections_created.append("#{file_path} - #{id}")
          ImportCollectionService.new(file_path, @base_dir).call
        end
      end
    end
    puts "Number of collections created: #{collections_created.size}"
    collections_created
  end

  def fix_collection_members
    #ToDo
  end

  def check_work(base_dir, model_name)
    raise "Model not found #{model_name}" unless %w(Etd GenericWork StudentWork).include?(model_name)
    model_dir = Rails.root.join(base_dir, model_name.to_s)
    has_work = []
    work_missing = []
    id_missing = []
    @base_dir = base_dir
    @work_ids = get_work_id_mappings
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      work_hash = parse_metadata_file(file_path)
      new_id =  @work_ids.fetch(work_hash["id"], nil)
      if new_id.present?
        work = model_name.constantize.find_by(id: new_id)
        if work.present?
          has_work.append("#{work_hash["title_tesim"]}, #{file_path}")
        else
          work_missing.append("#{work_hash["title_tesim"]}, #{file_path}")
        end
      else
        id_missing.append(file_path)
      end
    end
    puts "Number of #{model_name.to_s} created: #{has_work.size}"
    puts "Number of #{model_name.to_s} missing: #{work_missing.size}"
    puts "Number of #{model_name.to_s} with no mapped id: #{id_missing.size}"
    {
      "has_#{model_name.to_s.downcase}" => has_work,
      "#{model_name.to_s.downcase}_missing" => work_missing,
      'id_missing' => id_missing
    }
  end

  def check_filesets(base_dir, fileset_models=[])
    model_dir = Rails.root.join(base_dir, "FileSet")
    has_fileset = []
    fileset_missing = []
    id_missing = []
    discarded_filesets = []
    @base_dir = base_dir
    @fileset_ids = get_fileset_id_mappings
    discarded_fileset_data = read_discarded_filesets
    old_work_ids_list = get_work_old_ids(fileset_models)
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      fileset_hash = parse_metadata_file(file_path)
      new_id =  @fileset_ids.fetch(fileset_hash["id"], nil)
      if discarded_fileset_data.keys.include?(fileset_hash["id"])
        discarded_filesets.append("#{new_id}, #{file_path}")
      elsif fileset_has_parent?(old_work_ids_list, file_path)
        # Only check that which has been imported
        if new_id.present?
          fileset = Hyrax::FileSet.find_by(id: new_id)
          if fileset.present?
            has_fileset.append("#{new_id}, #{file_path}")
          else
            fileset_missing.append("#{new_id}, #{file_path}")
          end
        else
          id_missing.append(file_path)
        end
      end
    end
    puts "Number of filesets created: #{has_fileset.size}"
    puts "Number of filesets missing: #{fileset_missing.size}"
    puts "Number of filesets with no mapped id: #{id_missing.size}"
    puts "Number of filesets with no file in S3 (discarded): #{discarded_filesets.size}"
    {
      'has_fileset' => has_fileset,
      'fileset_missing' => fileset_missing,
      'id_missing' => id_missing,
      'discarded_filesets' => discarded_filesets
    }
  end

  def check_members(base_dir, model_name)
    members_not_equal = {}
    members_equal = []
    members_file_missing = []
    work_missing = []
    @base_dir = base_dir
    @work_ids = get_work_id_mappings
    model_dir = Rails.root.join(base_dir, model_name)
    # @fileset_ids = get_fileset_id_mappings
    # @work_ids = get_work_id_mappings
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      work_hash = parse_metadata_file(file_path)
      work = nil
      new_id =  @work_ids.fetch(work_hash["id"], nil)
      work = model_name.constantize if new_id.present?
      unless work.present?
        work_missing.append({'new_id' => new_id, 'file_path' => file_path})
        next
      end
      work_members_file = get_work_members_file(new_id, model_name)
      unless File.exist?(work_members_file)
        members_file_missing.append({'new_id' => new_id, 'file_path' => work_members_file})
        next
      end
      members_from_f = read_work_member_ids(work_members_file)

      members_set = work.member_ids.map(&:to_s).to_set
      members_from_f_set = members_from_f.keys.to_set
      if members_set == members_from_f_set
        members_equal.append(new_id)
      else
        in_both = members_set & members_from_f_set
        only_in_dataset = members_set - members_from_f_set
        only_in_file_members = members_from_f_set - members_set
        members_not_equal[new_id] = {
          'only_in_dataset' => only_in_dataset,
          'only_in_file_members' => only_in_file_members,
          'in_both' => in_both
        }
      end
    end
    puts "Number of works with all filesets linked: #{members_equal.size}"
    puts "Number of works with mismatched filesets: #{members_not_equal.size}"
    puts "Number of works not found: #{work_missing.size}"
    puts "Number of works with missing members file: #{members_file_missing.size}"
    {
      'members_equal' => members_equal,
      'members_not_equal' => members_not_equal,
      'members_file_missing' => members_file_missing,
      'dataset_missing' => work_missing
    }
  end

  def check_members_with_s3(base_dir, model)
    members_not_equal = {}
    members_equal = []
    work_id_missing = []
    @base_dir = base_dir
    @work_ids = get_work_id_mappings
    model_dir = Rails.root.join(@base_dir, model)
    Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
      work_hash = parse_metadata_file(file_path)
      work_id = @work_ids.fetch(work_hash["id"], nil)
      if work_id.present?
        result, detail = check_members_with_s3_for_work(work_id, model)
        if result
          members_equal.append(work_id)
        else
          members_not_equal[work_id] = detail
        end
      else
        work_id_missing.append(work_hash["id"])
      end
    end
    puts "Number of works with filesets in both: #{members_equal.size}"
    puts "Number of works with mismatched filesets: #{members_not_equal.size}"
    puts "Number of works with no mapped id: #{work_id_missing.size}"
    {
      'members_equal' => members_equal,
      'members_not_equal' => members_not_equal,
      'work_id_missing' => work_id_missing
    }
  end

  def read_discarded_filesets
    data = {}
    discard_log_file = Rails.root.join(@base_dir, "discarded_filesets.json")
    return data unless File.exist?(discard_log_file)
    File.foreach(discard_log_file) do |line|
      line = line.strip
      next if line.empty?
      begin
        data.merge!(JSON.parse(line))
      rescue JSON::ParserError
        next
      end
    end
    data
  end

  def id_is_discarded?(new_fileset_id, discarded_fileset_data)
    is_discarded = false
    discarded_fileset_data.each do |_k, v|
      is_discarded = true if v["new_id"] == new_fileset_id
    end
    is_discarded
  end

  def check_members_with_s3_for_work(work_id, model)
    work = nil
    work_filesets = []
    work_s3_object_keys = []
    if model == 'Dataset'
      work = Dataset.find_by(id: work_id)
      work.file_sets.each do |f|
        work_filesets.append(f.file_identifier)
      end
    elsif model == 'CrcDataset'
      work = Crc1280Experiment.find_by(id: work_id)
      work.all_file_sets.each do |f|
        work_filesets.append(f.file_identifier)
      end
    end
    s3 = S3StorageService.new
    s3.init_client

    list_of_objects = []
    bucket_id = s3.sanitise_name(ENV.fetch("S3_FILE_UPLOAD_BUCKET"))
    if s3.bucket_exists?(bucket_id)
      list_of_objects, _size = s3.list_all_objects(bucket_id, work_id)
    end
    if list_of_objects.any?
      list_of_objects.each do |fo|
        # Remove metadata files from the s3 list
        # Get just the key
        fn = fo[:key].split('/')[-1]
        work_s3_object_keys.append(fo[:key]) unless restricted_file_names?(fn)
      end
    end
    in_both = work_filesets.to_set & work_s3_object_keys.to_set
    only_in_work = work_filesets.to_set - work_s3_object_keys.to_set
    only_in_s3 = work_s3_object_keys.to_set - work_filesets.to_set
    puts "Checking #{work_id} filesets with s3"
    puts "Number of files in both: #{in_both.size}"
    puts "Number of files only in work: #{only_in_work.size}"
    puts "Number of files only in s3: #{only_in_s3.size}"
    result = false
    result = true if only_in_work.size == 0 and only_in_s3.size == 0
    return result, {
      'in_both' => in_both,
      'only_in_work' => only_in_work,
      'only_in_s3' => only_in_s3
    }
  end

  def reset_manifest_files
    downloads_dir = ENV.fetch('DOWNLOAD_PATH', '/shared/downloads')
    manifest_dir = Rails.root.join(downloads_dir, "__manifest")
    if Dir.exist?(manifest_dir)
      Dir.glob(Rails.root.join(manifest_dir, '*', 'manifest.json')).each do |manifest_file|
        FileUtils.rm_rf(manifest_file)
        FileUtils.touch(manifest_file)
      end
    end
  end

  def restricted_file_names?(file_path)
    file_name = file_path.split('/')[-1]
    parsed_file = YAML.load_file(Rails.root.join('config', 'restricted_files.yml'))
    parsed_file['restricted_file_names'].map(&:downcase).include?(file_name.downcase)
  end

  def fix_workflow(new_work_id, base_dir, model, file_path: nil)
    @base_dir = base_dir
    unless file_path.present?
      work_ids = get_work_id_mappings
      old_work_id = work_ids.key(new_work_id)
      file_path = Rails.root.join(base_dir, model, 'batch_1', "metadata_#{old_work_id}.json")
    end
    unless File.exist?(file_path)
      puts "Error - File #{file_path} does not exist. Workflow not fixed"
      return
    end
    work ||= Hyrax.query_service.find_by(id: new_work_id)
    delete_workflow(work)
    rerun_workflow(work, file_path, base_dir, model)
  end

  def delete_workflow(work)
    # Delete workflow
    gid = Hyrax::ValkyrieGlobalIdProxy.new(resource: work).to_global_id
    return if gid.blank?
    Sipity::Entity.where(proxy_for_global_id: gid.to_s).destroy_all
  end

  def rerun_workflow(work, file_path, base_dir, model)
    crc1280_id = {}
    os = ImportObjectService.new(file_path, base_dir, model, crc1280_id)
    os.method("process_workflow").call(work)
  end

  def make_workflow_tombstone(new_work_id)
    work ||= Hyrax.query_service.find_by(id: new_work_id)
    action_user = User.find_by(email: ENV.fetch('SYSTEM_PUBLICATION_MANAGER', 'publication_manager@hyrax'))
    action_name = "tombstone"
    subject = Hyrax::WorkflowActionInfo.new(work, action_user)
    workflow_action = Sipity::WorkflowAction(action_name, subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: workflow_action)
  end

  def fix_top_level_experiment_filesets
    files = Hyrax::FileSet.where(for_complex_type: ["CrcDataset"])
    files.each do |f|
      f.for_complex_type = "Crc1280Experiment"
      f.save
      f.save_index
    end
  end

end
