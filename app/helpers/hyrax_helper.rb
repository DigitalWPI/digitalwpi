# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include ::SdgService
  
  def sdg_facet_display(id)
    SdgService.label(id)
  end

  def stats_filter_path(document, start_date)
    if document.is_a?(FileSet)
      stats_file_path(document.id, start_date: start_date)
    else
      stats_work_path(document.id, start_date: start_date)
    end
  end

  def stats_filter_header(start_date, filters)
    header = if start_date.present?
      filters.key(params[:start_date]) || start_date.to_date.strftime("%b %Y")
    else
      Hyrax.config.analytics_start_date.to_date.strftime("%b %Y")
    end

    "From #{header}"
  end
end
