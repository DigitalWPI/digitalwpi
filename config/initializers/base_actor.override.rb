Rails.configuration.to_prepare do
  Hyrax::Actors::BaseActor.class_eval do
    private
    def clean_attributes(attributes)
      attributes.delete(:record_visibility) if attributes.key? :record_visibility
      attributes[:license] = Array(attributes[:license]) if attributes.key? :license
      attributes[:rights_statement] = Array(attributes[:rights_statement]) if attributes.key? :rights_statement
      remove_blank_attributes!(attributes).except('file_set')
    end
  end
end
