# frozen_string_literal: true
require 'rails_helper'
require 'cancan/matchers'

describe Hyrax::Ability, type: :model do
  let(:ability) { Ability.new(user) }
  subject { ability }
  describe "a user in the StudentWork_permission group" do
    let(:user) { FactoryBot.create(:user) }
    before do 
      allow(user).to receive_messages(groups: ['StudentWork_permission', 'registered']) 
    end
    it "can only create StudentWorks and attatch filesets" do 
      is_expected.to be_able_to(:create, StudentWork)
      is_expected.to be_able_to(:create, FileSet)
      is_expected.not_to be_able_to(:create, Etd)
      is_expected.not_to be_able_to(:create, GenericWork )
    end
  end
  describe "a user in the GenericWork_permission group" do
    let(:user) { FactoryBot.create(:user) }
    before do 
      allow(user).to receive_messages(groups: ['GenericWork_permission', 'registered']) 
    end
    it "can only create GenericWorks and attatch filesets" do 
      is_expected.to be_able_to(:create, GenericWork )
      is_expected.to be_able_to(:create, FileSet )
      is_expected.not_to be_able_to(:create, Etd )
      is_expected.not_to be_able_to(:create, StudentWork )
    end
  end
  describe "a user in the Etd_permission group" do
    let(:user) { FactoryBot.create(:user) }
    before do 
      allow(user).to receive_messages(groups: ['Etd_permission', 'registered']) 
    end
    it "can only create Etds and attatch filesets" do 
      is_expected.to be_able_to(:create, Etd)
      is_expected.to be_able_to(:create, FileSet)
      is_expected.not_to be_able_to(:create, StudentWork )
      is_expected.not_to be_able_to(:create, GenericWork )
    end
  end
  describe "a user in the Library_depositor group" do
    let(:user) { FactoryBot.create(:user) }
    before do 
      allow(user).to receive_messages(groups: ['Library_depositor', 'registered']) 
    end
    it "can only create Concerns and attatch filesets" do 
      is_expected.to be_able_to(:create, FileSet)
      is_expected.to be_able_to(:create, Etd)
      is_expected.to be_able_to(:create, StudentWork )
      is_expected.to be_able_to(:create, GenericWork )
    end
  end
  describe "a user in the GenericWork and Collection_permission group" do
    let(:user) { FactoryBot.create(:user) }
    before do 
      allow(user).to receive_messages(groups: ['GenericWork_permission','Collection_permission', 'registered']) 
    end
    it "can only create Concerns and attatch filesets" do 
      is_expected.to be_able_to(:create, GenericWork )
      is_expected.to be_able_to(:create, FileSet )
      is_expected.to be_able_to(:create, Collection )
      is_expected.not_to be_able_to(:create, Etd )
      is_expected.not_to be_able_to(:create, StudentWork )
    end
  end
end