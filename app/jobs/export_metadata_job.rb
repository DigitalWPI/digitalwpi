class ExportMetadataJob < Hyrax::ApplicationJob
  def perform(update=true, models_to_export=%w[Collection Etd GenericWork StudentWork FileSet User Role Id], base_dir="/tmp/metadata_export")
    ems = ExportMetadataService.new(update=update, models_to_export=models_to_export, base_dir=base_dir)
    ems.export
  end
end
