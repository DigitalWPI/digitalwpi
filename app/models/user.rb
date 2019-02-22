# frozen_string_literal: true
class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise_modules = [:omniauthable, :rememberable, :trackable, 
                    omniauth_providers: [:shibboleth], authentication_keys: [:uid]]
  devise_modules.prepend(:database_authenticatable, :registerable, :recoverable)
  devise_modules.prepend(:validatable)
  devise(*devise_modules)
  # devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable

  # When a user authenticates via shibboleth, find their User object or make
  # a new one. Populate it with data we get from shibboleth.
  # @param [OmniAuth::AuthHash] auth
  def self.from_omniauth(auth)
    # Rails.logger.debug "auth = #{auth.inspect}"
    # Uncomment the debugger above to capture what a shib auth object looks like for testing
    user = where(provider: auth.provider, uid: auth.info.uid).first_or_create
    user.display_name = auth.info.display_name
    user.uid = auth.info.uid
    user.email = auth.info.mail
    user.save
    user
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    email
  end

  module Hyrax::User
    module ClassMethods
      def find_or_create_system_user(user_key)
        u = ::User.find_or_create_by(uid: user_key)
        u.display_name = user_key
        u.email = "#{user_key}@email.unc.edu"
        u.password = ('a'..'z').to_a.shuffle(random: Random.new).join if AuthConfig.use_database_auth?
        u.save
        u
      end
    end
  end
end
