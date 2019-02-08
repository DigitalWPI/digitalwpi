# frozen_string_literal: true
require 'rails_helper'
require 'cancan/matchers'

def create_collection(user, type_gid, id, options)
  col = Collection.where(id: id)
  return col.first if col.present?
  col = Collection.new(id: id)
  col.attributes = options.except(:visibility)
  col.apply_depositor_metadata(user)
  col.collection_type_gid = type_gid
  col.visibility = options[:visibility]
  col.save
  Hyrax::Collections::PermissionsCreateService.create_default(collection: col)
  col
end
def create_public_collection(user, type_gid, id, options)
  options[:visibility] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  create_collection(user, type_gid, id, options)
end
def create_collection_type(machine_id, options)
  coltype = Hyrax::CollectionType.find_by_machine_id(machine_id)
  return coltype if coltype.present?
  default_options = {
    nestable: false, discoverable: false, sharable: false, allow_multiple_membership: false,
    require_membership: false, assigns_workflow: false, assigns_visibility: false,
    participants: [{ agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE, agent_id: ::Ability.admin_group_name, access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS },
                   { agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE, agent_id: ::Ability.registered_group_name, access: Hyrax::CollectionTypeParticipant::CREATE_ACCESS }]
  }
  final_options = default_options.merge(options.except(:title))
  Hyrax::CollectionTypes::CreateService.create_collection_type(machine_id: machine_id, title: options[:title], options: final_options)
end

describe Hyrax::Ability, type: :model do
  let(:ability) { Ability.new(user) }
  let(:iqp) { create_public_collection(nil, nestable_gid, 'iqp', title: ['IQP'], description: ['IQPs ONLY']) }
  let(:mqp) { create_public_collection(nil, nestable_gid, 'mqp', title: ['MQP'], description: ['MQPs ONLY']) }
  subject { ability }
  describe "a user in the qualifying_project manager group" do
    
    let(:creator) { FactoryBot.create(:user) }
    let(:nestable_gid) { create_collection_type('nestable_collection',
            { title: 'Nestable Collection', description: 'Sample collection type that allows nesting of collections.',
            nestable: true, discoverable: true, sharable: true, allow_multiple_membership: true }).gid }
    let(:user) { FactoryBot.create(:user) }
    let(:work) { FactoryBot.create(:public_student_work) }
    # let(:iqp_work) { FactoryBot.create(:public_student_work) }
    # let(:mqp_work) { FactoryBot.create(:public_student_work) }
    before do 
      allow(user).to receive_messages(groups: ['qualifying_project', 'registered']) 
    end
    it "can only create StudentWork work concerns" do 
      is_expected.not_to be_able_to(:create, GenericWork)
      is_expected.not_to be_able_to(:create, Etd)
      is_expected.to be_able_to(:create, StudentWork )
    end
    it "should be able to deposit in iqp and mqp" do 
      is_expected.to be_able_to(:deposit, iqp)
      is_expected.to be_able_to(:deposit, mqp)
    end
    # it "can edit all the works already in relevant collections" do
    #   is_expected.to be_able_to(:edit, iqp_work)
    #   is_expected.to be_able_to(:edit, mqp_work)
    #   is_expected.not_to be_able_to(:edit, work)
    # end
  end

end