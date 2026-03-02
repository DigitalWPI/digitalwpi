Rails.configuration.to_prepare do
  Hyrax::Collections::CollectionMemberSearchService.class_eval do
    # Allowed sorting of collection members by the sort param that missing in Hyrax v3.3.0
    def available_member_works
      sort_field = user_params[:sort]
      response, _docs = search_results do |builder|
        builder.search_includes_models = :works
        builder.merge(sort: sort_field)
        builder
      end
      response
    end
  end
end