class ExportMetadataJob < Hyrax::ApplicationJob
  def perform(update=false, models_to_export=%w[Collection Etd GenericWork StudentWork FileSet User Role])
    ems = ExportMetadataService.new(update=update, models_to_export=models_to_export)
    ems.export
  end
end
