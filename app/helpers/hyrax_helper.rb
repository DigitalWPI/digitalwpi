# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include ::SdgService
  
  def sdg_facet_display(id)
    SdgService.label(id)
  end

end
