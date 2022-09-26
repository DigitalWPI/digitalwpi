# frozen_string_literal: true
# tests for database auth / shib / azure
require 'rails_helper'
RSpec.describe User do
  let(:user) { build(:user) } # creates a new dog user

  describe 'omniauthable user' do
    it "has a uid field" do
      expect(user.email).not_to be_empty
    end
    it "can have a provider" do
      expect(described_class.new.respond_to?(:provider)).to eq true
    end
  end
end
