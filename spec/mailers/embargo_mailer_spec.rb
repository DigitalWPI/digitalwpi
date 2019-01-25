# frozen_string_literal: true
require 'rails_helper'
require 'rake'

describe EmbargoMailer do
  context "an embargoed work" do
    let(:embargo_date) { Time.zone.today + 30 }
    let(:user) { FactoryBot.create(:user) }
    let(:work) { FactoryBot.create(:embargoed_generic_work, user: user, embargo_release_date: embargo_date) }
    before { described_class.deliveries = [] }

    it "sends the EmbargoMailer.notify email" do
      load File.expand_path("../../../lib/tasks/UC_embargo_manager.rake", __FILE__)
      Rake::Task.define_task(:environment)
      work

      Rake::Task['embargo_manager:notify'].invoke
      expect(described_class.deliveries.length).to eq(1)
    end
  end

  context 'class methods' do
    describe 'notify should' do
      it 'return a mail object with proper to and from' do
        expect(described_class.notify('user1@example.com', 'my test work', 5).to).to include('user1@example.com')
        expect(described_class.notify('user1@example.com', 'my test work', 5).from).to include(ENV['MAILUSER'])
      end
    end
  end
end
