# frozen_string_literal: true
class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role if current_user.admin?

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end
end
