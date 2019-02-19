module Hydra
  module RoleManagement
    module UserRolesBehavior
      extend ActiveSupport::Concern

      included do
        load_and_authorize_resource :role
      end

      def create
        authorize! :add_user, @role
        u = find_user
        if u
          u.roles << @role
          u.save!
          redirect_to role_management.role_path(@role)
        else
          redirect_to role_management.role_path(@role), :flash=> {:error=>"Unable to find the user #{params[:user_key]}"}
        end
      end

      def destroy
        # byebug
        authorize! :remove_user, @role

        @role.users.delete(::User.find_by_user_key(params[:id].gsub('-dot-','.')))
        redirect_to role_management.role_path(@role)
      end

      protected

      def find_user
        ::User.send("find_by_#{find_column}".to_sym, params[:user_key])
      end

      def find_column
        Devise.authentication_keys.first
      end
    end
  end
end

