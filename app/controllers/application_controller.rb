# frozen_string_literal: true
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  skip_after_action :discard_flash_if_xhr
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  private

    # override devise helper and route to CC.new when parameter is set
    def after_sign_in_path_for(_resource)
      cookies[:login_type] = "local"
      return root_path unless parameter_set?
      dashboard_works_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      root_path
    end

    def parameter_set?
      session['user_return_to'] == '/'
    end
end
