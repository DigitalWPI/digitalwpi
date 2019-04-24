# frozen_string_literal: true

class CallbacksController < Devise::OmniauthCallbacksController
  def saml
    if current_user
      redirect_to Hyrax::Engine.routes.url_helpers.dashboard_path
    else
      retrieve_saml_attributes
      create_or_update_user
      sign_in_saml_user
    end
  end

  def failure
    set_flash_message! :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to after_omniauth_failure_path_for(resource_name)
  end

  private

    def retrieve_saml_attributes
      @omni = request.env["omniauth.auth"]
      @email = @omni.extra.raw_info.attributes['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'][0]
    end

    def create_or_update_user
      if user_exists?
        update_saml_attributes if user_has_never_logged_in?
      else
        create_user
      end
    end

    def sign_in_saml_user
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      cookies[:login_type] = "saml"
      flash[:notice] = "You are now signed in as #{@user.name} (#{@user.email})"
    end

    def user_exists?
      @user = find_by_provider_and_email
      return true unless @user.nil?
    end

    def find_by_provider_and_email
      User.where(provider: @omni['provider'], email: @omni.extra.raw_info.attributes['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'][0]).first
    end

    def update_saml_attributes
      update_user_saml_attributes
    end

    def user_has_never_logged_in?
      @user.sign_in_count.zero?
    end

    def create_user
      @user = User.create provider: @omni.provider,
                          uid: @omni.uid,
                          email: @email,
                          password: Devise.friendly_token[0, 20],
                          display_name: @omni.extra.raw_info.attributes['http://schemas.microsoft.com/identity/claims/displayname'][0]
    end

    def update_user_saml_attributes
      @user.name         = @omni.extra.raw_info.attributes['http://schemas.microsoft.com/identity/claims/displayname'][0]
      @user.save
    end
end
