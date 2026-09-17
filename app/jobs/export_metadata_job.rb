class ExportMetadataJob < Hyrax::ApplicationJob
  def perform(update=true, models_to_export=%w[Collection Etd GenericWork StudentWork FileSet User Role Id])
    ems = ExportMetadataService.new(update=update, models_to_export=models_to_export)
    ems.export
  end
end
