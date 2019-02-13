# frozen_string_literal: true
class Ability
  # class Ability this seems to be for only the User class # user # user.ability # User
  # it adds functionality to group users ability to crud objects and view certain things in the app
  # for example this is where we say, if a user is an admin, let them create works.
  
  include Hydra::Ability
  include Hyrax::Ability
  # allow all users to make works and stuff.
  # self.ability_logic += [:everyone_can_create_curation_concerns]

  #allow users in group to edit things
  self.ability_logic += [:StudentWork_permission,
                         :GenericWork_permission,
                         :Etd_permission,
                         :library_depositor,
                         :Collection_permission]
  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    can :create, curation_concerns_models if current_user.admin?
    # cannot [:manage], Collection unless current_user.admin? 
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role if current_user.admin?
    # Limits creating new objects to a specific group
    #
    # StudentWork_permission if user_groups.include? 'qualifying_project'
  end
  def grant_recursive_collect_permission(collection_id)
    ##
    # takes in the id of a collection, and grants the current user show edit and deposit power to all collections
    # finds Collection object calls private method recursive_edit_and_deposit on said object.
    #
    specific_collection = Collection.find(collection_id)
    recursive_edit_and_deposit(specific_collection)
  end
  private
    def recursive_edit_and_deposit(specific_collection)
      can [:show,:edit,:deposit], specific_collection
      specific_collection.member_objects.each  do |sub_col|
        recursive_edit_and_deposit(sub_col) if sub_col.is_a? Collection 
      end
    end

    def StudentWork_ability
      can [:create,:index, :edit, :update], FileSet #create files attached to works
      can [:show, :create, :index, :update, :edit], StudentWork #create student works
    end
    def GenericWork_ability
      can [:create,:index, :edit, :update], FileSet #create files attached to works
      can [:show, :create, :index, :update], GenericWork #create generic works
    end
    def Etd_ability
      can [:create,:index, :edit, :update], FileSet #create files attached to works
      can [:show, :create, :index, :update], Etd #create Etds
    end
    def Collection_ability
      can [:create,:index, :edit, :update], FileSet #create files attached to works
      can [:show, :create, :index, :edit, :update], Collection #create files attached to works
    end
    #set the permisions for a user who is able to edit and create certaininclude Hyrax::Ability collections
    def StudentWork_permission
      if user_groups.include? 'StudentWork_permission'    
        StudentWork_ability()
      end
    end
    def GenericWork_permission
      if user_groups.include? 'GenericWork_permission'    
        GenericWork_ability()
      end
    end
    def Etd_permission
      if user_groups.include? 'Etd_permission'    
        Etd_ability()
      end
    end
    def Collection_permission
      if user_groups.include? 'Collection_permission'
        Collection_ability()
      end
    end
    def library_depositor
      if user_groups.include? 'Library_depositor'
        # can create anything
        StudentWork_ability()
        GenericWork_ability()
        Etd_ability()
        Collection_ability()
      end
    end

    ##
    # this function everyone_can_create_curation_concerns gives all the ability to create works 
    # it does so by seeing if the user is registered, if so it grants the cancan ability create
    # to the list of Curation Concerns (work types + file sets and collecitons ) returned by the method curation_concerns_models().
    # 
    def everyone_can_create_curation_concerns()
      return unless registered_user?
      can :create, curation_concerns_models
    end
    ##
    # returns the list of things that any shmuck can create. by default its everything 
    #
    def curation_concerns_models()

      [::FileSet, ::Collection] + Hyrax.config.curation_concerns # [::FileSet, ::Collection] + [Etd, GenericWork, StudentWork]
    end
end
