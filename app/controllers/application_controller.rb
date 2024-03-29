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
  skip_before_action :verify_authenticity_token, only: :saml
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

    def append_info_to_payload(payload)
      super
      payload[:host] = request.host
      payload[:remote_ip] = request.remote_ip
      payload[:user_id] = current_user.try(:id)
      payload[:referer] = request.referer.to_s
      payload[:request_id] = request.uuid
      payload[:user_agent] = request.user_agent
      payload[:xhr] = request.xhr? ? 'true' : 'false'
    end
end
