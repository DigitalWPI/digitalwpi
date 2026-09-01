module ImportHelper
  def mapping_ids_file_path
    {
      'Work' => Rails.root.join(@base_dir, "mapping.json"),
      'Collection' => Rails.root.join(@base_dir, "collection_mapping.json"),
      'FileSet' => Rails.root.join(@base_dir, "fileset_mapping.json")
    }
  end

  def get_work_id_mappings
    get_id_mappings('Work')
  end

  def get_collection_id_mappings
    get_id_mappings('Collection')
  end

  def get_fileset_id_mappings
    get_id_mappings('FileSet')
  end

  def get_id_mappings(typ)
    unless mapping_ids_file_path.keys.include?(typ)
      Rails.logger.error("Id mapping of type #{typ} not found")
      return { }
    end
    ids_file_path = mapping_ids_file_path[typ]
    unless File.exist?(ids_file_path)
      Rails.logger.error("File #{ids_file_path} not found")
      return { }
    end
    data = File.read(ids_file_path)
    JSON.parse(data)
  end

  def get_work_old_ids(models_with_fileset)
    object_ids = []
    models_with_fileset.each do |model|
      next if %w(FileSet Collection).include?(model)
      model_dir = Rails.root.join(@base_dir, model)
      if Dir.exist?(model_dir)
        Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
          if File.file?(file_path) and file_path.end_with?('.json')
            obj_id = File.basename(file_path, ".json").gsub("metadata_", "")
            object_ids.append(obj_id)
          end
        end
      end
    end
    object_ids
  end


  def get_member_collection_ids(check_exists: false)
    collection_members = []
    @metadata.fetch('member_of_collection_ids_ssim', []).each do |m_id|
      new_id = @collection_ids.fetch(m_id, nil)
      if new_id.present?
        if new_id and check_exists
          parent_collection = Collection.find(new_id)
          collection_members << parent_collection.id if parent_collection
        elsif new_id
          collection_members << new_id
        end
      end
    end
    collection_members
  end

  def get_member_work_ids(check_exists: false)
    Rails.logger.warn("Works ids is empty") if @work_ids.empty?
    work_members = []
    student_work_ids_old = get_work_old_ids(['StudentWork'])
    generic_work_ids_old = get_work_old_ids(['GenericWork'])
    edt_ids_old = get_work_old_ids(['Etd'])

    @metadata.fetch('member_ids_ssim', []).each do |m_id|
      new_id = @work_ids.fetch(m_id, nil)
      new_id = @fileset_ids.fetch(m_id, nil) unless new_id
      if new_id.present?
        if check_exists
          if student_work_ids_old.include?(m_id)
            parent_work = StudentWork.find(new_id)
            work_members << parent_work.id if parent_work
          elsif generic_work_ids_old.include?(m_id)
            parent_work = GenericWork.find(new_id)
            work_members << parent_work.id if parent_work
          elsif edt_ids_old.include?(m_id)
            parent_work = Etd.find(new_id)
            work_members << parent_work.id if parent_work
          end
        else
          work_members << new_id
        end
      end
    end
    work_members
  end

  def get_fileset_parent_id
    old_id = get_fileset_parent_old_id(@metadata)
    return nil unless old_id.present?
    @work_ids.fetch(old_id, nil)
  end


  def fileset_has_parent?(work_ids_old, file_path)
    metadata = parse_metadata_file(file_path)
    parent_work_id = get_fileset_parent_old_id(metadata)
    if parent_work_id and work_ids_old.include?(parent_work_id)
      return true
    end
    false
  end

  def get_fileset_parent_old_id(metadata)
    metadata.fetch("parent_work_id", nil)
  end

  def parse_metadata_file(file_path)
    data = File.read(file_path)
    HashWithIndifferentAccess.new(JSON.parse(data))
  end

  def write_json(file_path, data)
    File.open(file_path,"w") do |f|
      f.write(JSON.pretty_generate(data))
    end
  end

  def parse_roles(roles, comma_separated: true)
    new_roles = []
    return new_roles unless roles.present?
    roles.each do |role|
      new_role = role
      if role == "crc_1280_manager" or role == "crc_1280_member"
        new_role = role
      elsif role.start_with?("crc_1280") and role.end_with?("manager")
        regex1 = /crc_1280_(.*)_manager/
        match1 = role.match(regex1)
        new_role = nil
        if match1
          new_id = @collection_ids.fetch(match1[1], nil)
          if comma_separated and new_id
            new_role = "crc_1280_group_manager, #{new_id}"
          elsif new_id
            new_role = "crc_1280_#{new_id}_manager"
          end
        end
      elsif role.start_with?("crc_1280") and role.end_with?("member")
        regex2 = /crc_1280_(.*)_member/
        match2 = role.match(regex2)
        new_role = nil
        if match2
          new_id = @collection_ids.fetch(match2[1], nil)
          if comma_separated and new_id
            new_role = "crc_1280_group_member, #{new_id}"
          elsif new_id
            new_role = "crc_1280_#{new_id}_member"
          end
        end
      end
      new_roles.append(new_role) if new_role
    end
    new_roles
  end

  def update_access_controls(record)
    edit_access_group = @metadata.fetch("edit_access_group_ssim", [])
    record.edit_groups = parse_roles(edit_access_group, comma_separated: false) if edit_access_group.present?
    read_access_group = @metadata.fetch("read_access_group_ssim", [])
    record.read_groups = parse_roles(read_access_group, comma_separated: false) if read_access_group.present?
    record.edit_users = @metadata["edit_access_person_ssim"].presence || []
    record.read_users = @metadata["read_access_person_ssim"].presence || []
    record.save_acl
  end

  def get_work_members_dir(model)
    Rails.root.join(@base_dir, "#{model}_members")
  end

  def get_work_members_file(work_id_new, model)
    work_members_dir = get_work_members_dir(model)
    Rails.root.join(work_members_dir, "#{work_id_new}.json")
  end

  def write_work_members(fileset_id_new, parent_id_new, s3_key, model)
    work_members_dir = get_work_members_dir(model)
    FileUtils.mkdir_p work_members_dir unless Dir.exist?(work_members_dir)
    work_members_file = get_work_members_file(parent_id_new, model)
    data = { 'id' => fileset_id_new, 's3_key' => s3_key }
    File.open(work_members_file, 'a') do |f|
      f.puts(data.to_json)
    end
  end

  def read_work_member_ids(file_path)
    members = {}
    File.foreach(file_path) do |line|
      line = line.strip
      next if line.empty?
      begin
        line_hash = JSON.parse(line)
        members[line_hash['id']] = line_hash['s3_key']
      rescue JSON::ParserError
        next
      end
    end
    members
  end

  def cleanup_work_members_dir(model)
    work_members_dir = get_work_members_dir(model)
    FileUtils.rm_rf work_members_dir if Dir.exist?(work_members_dir)
  end
end
