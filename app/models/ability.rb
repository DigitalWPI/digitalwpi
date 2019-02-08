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
  self.ability_logic += [:StudentWork_permission,:GenericWork_permission,:specail_collections_depositor]
  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user

    # cannot [:manage], Collection unless current_user.admin? 
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role if current_user.admin?
    # Limits creating new objects to a specific group
    #
    # StudentWork_permission if user_groups.include? 'qualifying_project'
  end
  private
    #set the permisions for a user who is able to edit things in qualifying projects collections
    def StudentWork_permission
      if user_groups.include? 'StudentWork_permission'    
        can [:create,:index, :edit, :update], FileSet #create files attached to works
        can [:show, :create, :index, :update, :edit], StudentWork #create student works
      end
    end
    def GenericWork_permission
      if user_groups.include? 'GenericWork_permission'    
        GenericWork_ability
      end
    end
    def GenericWork_ability
      can [:create,:index, :edit, :update], FileSet #create files attached to works
      can [:show, :create, :index, :update], GenericWork #create student works
    end
    def qualifying_project_permission
      if user_groups.include? 'qualifying_project'    
        can [:manage], Collection
      end
    end
    def specail_collections_depositor
      # broken function cause if iqp and mqp dont exist, it dies
      if user_groups.include? 'student_worker'
        iqp = Collection.find('special_collection')
        # mqp = Collection.find('mqp')
        GenericWork_ability()
        can [:view_admin_show,:deposit,:edit,:update], iqp #deposit into collection IQP
        # can [:view_admin_show,:deposit,:edit,:update], mqp #deposit into collection MQP
        can [:edit], iqp.member_objects# + mqp.member_objects #edit all things in these collections
      else
        return
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
