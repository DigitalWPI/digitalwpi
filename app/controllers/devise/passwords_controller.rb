# frozen_string_literal: true

require Devise::Engine.root.join('app/controllers/devise/passwords_controller.rb')
class Devise::PasswordsController
  # POST /resource/password
  def create
    if resource_params['email'].end_with? '@wpi.edu'
      redirect_to login_path
      flash[:notice] = "You cannot reset passwords for @wpi.edu accounts.  Use your WPI Central Login instead."
    else
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    end
  end
end
