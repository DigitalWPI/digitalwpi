# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ControllerUtils, type: :concern do
  let(:controller_class) do
    Class.new do
      include ControllerUtils
      attr_accessor :curation_concern

      def params
        @params ||= ActionController::Parameters.new
      end

      def _curation_concern_type
        @curation_concern_type ||= double(model_name: double(param_key: 'etd'))
      end
    end
  end

  let(:controller) { controller_class.new }

  describe '#add_date_and_creator_to_note' do
    before do
      controller.curation_concern = double(editorial_note: nil)
      controller.params[:etd] = { 'editorial_note' => 'Editorial note has nothing' }
      allow(controller).to receive(:current_user).and_return(double(email: 'admin@example.com', name: 'Admin User'))
    end

    it 'serializes editorial_note to a JSON array of note hashes' do
      controller.send(:add_date_and_creator_to_note)

      parsed_value = JSON.parse(controller.params[:etd]['editorial_note'])

      expect(parsed_value).to contain_exactly(
        a_hash_including(
          'note' => 'Editorial note has nothing',
          'user_id' => 'admin@example.com',
          'user_name' => 'Admin User'
        )
      )
      expect(parsed_value.first['created']).to be_present
    end
  end
end
