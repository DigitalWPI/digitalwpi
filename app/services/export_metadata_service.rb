class ExportMetadataService
  def initialize(update=false, models_to_export=%w[Collection Etd GenericWork StudentWork FileSet User Role], base_dir="/tmp/metadata_export")
    @parent_child_objects = {}
    @update = update
    @models_to_export = models_to_export
    @work_models = [GenericWork, StudentWork, Etd]
    @base_dir = base_dir
  end

  def export
    if @models_to_export.include?('Collection')
      export_objects(Collection)
    end
    if @models_to_export.include?('Etd')
      export_objects(Etd)
    end
    if @models_to_export.include?('GenericWork')
      export_objects(GenericWork)
    end
    if @models_to_export.include?('StudentWork')
      export_objects(StudentWork)
    end
    if @models_to_export.include?('FileSet')
      export_objects(FileSet)
    end
    if @models_to_export.include?('User')
      export_users
    end
    if @models_to_export.include?('Role')
      export_roles
    end
  end

  private

  def batch_dir(model_name, batch_number)
    Rails.root.join(@base_dir, model_name, "batch_#{batch_number}")
  end

  def file_path(object_id, model_name, batch_number)
    Rails.root.join(batch_dir(model_name, batch_number), "metadata_#{object_id}.json")
  end

  def export_objects(object_model)
    label = object_model.model_name.to_s
    start = 0
    rows = 1000
    page = 1
    loop do
      Rails.logger.info("Starting #{label} batch #{page} export")
      objects = get_objects(object_model, start: start, rows: rows)
      Rails.logger.info("Total number of #{label}s in batch_#{page} #{objects.size}")
      FileUtils.mkdir_p(batch_dir(label, page))
      objects.each do |object|
        Rails.logger.info("Starting export of #{label} #{object[:id]}")
        data = metadata(object)
        if data[:has_model_ssim].include?('FileSet') && !data[:parent_work_id].present?
          orphan_dir = batch_dir("OrphanFileSet", page)
          FileUtils.mkdir_p(orphan_dir) unless Dir.exist?(orphan_dir)
          metadata_file = file_path(object[:id], "OrphanFileSet", page)
        else
          metadata_file = file_path(object[:id], label, page)
        end
        next if File.exist?(metadata_file) and not @update
        File.delete(metadata_file) if File.exist?(metadata_file)
        File.open(metadata_file, 'a+') do |file|
          file.write(JSON.pretty_generate(data))
        end
      end
      break if objects.size < rows
      start += rows
      page += 1
    end
    Rails.logger.info("Completed export of #{label}")
  end

  def metadata(object)
    file_additional_metadata = {}
    if object[:has_model_ssim].include?('FileSet')
      parent_id = @parent_child_objects.find { |_parent, file_sets| file_sets.include?(object[:id]) }&.first
      file_additional_metadata[:parent_work_id] = parent_id
    end
    object.merge(file_additional_metadata)
  end

  def get_objects(object_model, start: 0, rows: 1000)
    objects = Hyrax::SolrService.query("has_model_ssim:(#{object_model})", start: start, rows: rows)

    if @work_models.include?(object_model)
      objects.each do |obj|
        @parent_child_objects[obj['id']] = obj[:file_set_ids_ssim] || []
      end
    end

    objects
  end

  def export_users
    count = 0
    User.all.each do |u|
      count = count + 1
      page = count/1000 + 1
      u_dir = batch_dir('User', page)
      FileUtils.mkdir_p(u_dir) unless Dir.exist?(u_dir)
      metadata_file = file_path(u.id, 'User', page)
      next if File.exist?(metadata_file) and not @update
      user_attributes = u.attributes.compact
      user_attributes['roles'] = u.roles.collect {|r| r.name}
      user_attributes['workflow_roles'] = prepare_user_workflow_roles(u)
      File.delete(metadata_file) if File.exist?(metadata_file)
      File.open(metadata_file, 'a+') do |file|
        file.write(JSON.pretty_generate(user_attributes))
      end
    end
  end

  def export_roles
    count = 0
    Role.all.each do |r|
      label = 'Role'
      count = count + 1
      page = count/1000 + 1
      r_dir = batch_dir(label, page)
      FileUtils.mkdir_p(r_dir) unless Dir.exist?(r_dir)
      metadata_file = file_path(r.id, label, page)
      next if File.exist?(metadata_file) and not @update
      role_attributes = r.attributes.compact
      role_attributes['users'] = r.users.collect {|u| u.email}
      File.delete(metadata_file) if File.exist?(metadata_file)
      File.open(metadata_file, 'a+') do |file|
        file.write(JSON.pretty_generate(role_attributes))
      end
    end
  end

  def prepare_user_workflow_roles(user)
    user_agent = Sipity::Agent.find_by(proxy_for_id: user.id, proxy_for_type: 'User')
    return [] unless user_agent
    workflow_roles = Sipity::WorkflowRole.joins(:workflow_responsibilities).where(sipity_workflow_responsibilities: { agent_id: user_agent.id })
    workflow_roles_data = []
    workflow_roles.each do |workflow_role|
      workflow_roles_data << { workflow_name: workflow_role.workflow.name, role_name: workflow_role.role.name }
    end
    workflow_roles_data
  end
end
