# frozen_string_literal: true

Bulkrax.setup do |config|
  config.required_elements = []
  config.field_mappings = {
    "Bulkrax::CsvParser" => {
      "source" => { from: ["source"], source_identifier: true },
      'parents' => { from: ['parents'], related_parents_field_mapping: true },
      'children' => { from: ['children'], related_children_field_mapping: true }
    }
  }
end

# Sidebar for hyrax 3+ support
Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
