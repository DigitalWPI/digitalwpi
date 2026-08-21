class ImportAllObjectsJob < ApplicationJob
  queue_as :default

  def perform(base_dir, models_to_import=%w(Role User Collection StudentWork GenericWork Etd FileSet), fileset_models_to_ingest=%w(StudentWork GenericWork Etd))
    @base_dir = base_dir
    raise "Directory #{@base_dir} does not exist" unless Dir.exist?(@base_dir)
    old_work_ids_list = models_to_import.include?('FileSet') ? get_work_old_ids(fileset_models_to_ingest) : []

    models_to_import.each do |model|
      model_dir = Rails.root.join(@base_dir, model)
      raise "Directory #{model_dir} does not exist" unless Dir.exist?(model_dir)

      Dir.glob(Rails.root.join(model_dir, '*', '*')).each do |file_path|
        if File.file?(file_path)
          if model == 'Role'
            ImportRoleService.new(file_path, @base_dir).call
          elsif model == 'User'
            ImportUserService.new(file_path, @base_dir).call
          elsif model == 'Collection'
            ImportCollectionService.new(file_path, @base_dir).call
          elsif model == 'FileSet'
            import_object = fileset_has_parent?(old_work_ids_list, file_path)
            ImportFilesetService.new(file_path, @base_dir).call if import_object
          else
            ImportObjectService.new(file_path, @base_dir, model).call
          end
        end
      end
    end
  end
end