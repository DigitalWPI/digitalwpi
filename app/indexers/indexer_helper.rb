module IndexerHelper
  def all_metadata_values
    values = [
      object.title,
      object.description,
      object.keyword,
      object.creator,
      object.contributor,
      object.publisher,
      # object.format,
      object.identifier,
      object.subject,
      # object.based_near_label,
      object.language,
      object.rights_statement,
      object.license,
      object.resource_type,
      object.alternate_title,
      object.award,
      object.year
    ]
    values.append(object.advisor) if object.class.method_defined?(:advisor)
    values.append(object.sponsor) if object.class.method_defined?(:sponsor)
    values.append(object.center) if object.class.method_defined?(:center)
    # values.flatten!
    # values.reject(&:blank?)
    flattened_values = []
    values.each do |val|
      flattened_values += Array(val).reject(&:blank?)
    end
    flattened_values
  end
end