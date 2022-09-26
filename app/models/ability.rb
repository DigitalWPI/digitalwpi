class Ability
  include Hydra::Ability
  
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end
  end


    ##
    # this function everyone_can_create_curation_concerns gives all the ability to create works 
    # it does so by seeing if the user is registered, if so it grants the cancan ability create
    # to the list of Curation Concerns (work types + file sets and collecitons ) returned by the method curation_concerns_models().
    # 
    def everyone_can_create_curation_concerns()
      return unless registered_user?
      can :create, [::FileSet, ::Collection, ::Etd, ::GenericWork, ::StudentWork]
    end
    ##
    # returns the list of things that any shmuck can create. by default its everything 
    #
    def curation_concerns_models()

      [::FileSet, ::Collection, ::Etd, ::GenericWork, ::StudentWork]
    end
end
