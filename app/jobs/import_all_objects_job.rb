class ImportAllObjectsJob < ApplicationJob
  queue_as :default

  def perform(base_dir, models_to_import=%w(Role User Collection StudentWork GenericWork Etd FileSet), fileset_models_to_ingest=%w(StudentWork GenericWork Etd))
    ImportAllObjectsService.new(base_dir, models_to_import, fileset_models_to_ingest).call
  end
end