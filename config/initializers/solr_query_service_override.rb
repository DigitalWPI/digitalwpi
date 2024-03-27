Rails.configuration.to_prepare do
  Hyrax::SolrQueryService.class_eval do
    def get(**args)
      solr_service.get(build, **args)
    end
  end
end