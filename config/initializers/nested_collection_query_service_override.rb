Rails.configuration.to_prepare do
  Hyrax::Collections::NestedCollectionQueryService.module_eval do
    def self.child_nesting_depth(child:, scope:)
      return 1 if child.nil?

      builder = Hyrax::SearchBuilder.new(scope).with({
        q: "#{Samvera::NestingIndexer.configuration.solr_field_name_for_storing_pathnames}:/.*#{child.id}.*/",
        sort: "#{Samvera::NestingIndexer.configuration.solr_field_name_for_deepest_nested_depth} desc"
      })
      builder.rows = 1
      query = clean_lucene_error(builder: builder)
      response = scope.repository.search(query).documents.first
      return 1 if response.nil?
      descendant_depth = response[Samvera::NestingIndexer.configuration.solr_field_name_for_deepest_nested_depth]

      child_depth = Hyrax::Collections::NestedCollectionQueryService::NestingAttributes.new(id: child.id, scope: scope).depth || 1
      nesting_depth = descendant_depth - child_depth + 1
      nesting_depth.positive? ? nesting_depth : 1
    end
    private_class_method :child_nesting_depth
  
    def self.parent_nesting_depth(parent:, scope:)
      return 1 if parent.nil?
      Hyrax::Collections::NestedCollectionQueryService::NestingAttributes.new(id: parent.id, scope: scope).depth || 1
    end
    private_class_method :parent_nesting_depth
  end
end
