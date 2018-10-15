require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Etd', js: false do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      DatabaseCleaner.clean
      ActiveFedora::Cleaner.clean!
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
    end

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      # choose "payload_concern", option: "Etd"
      # click_button "Create work"

      expect(page).to have_content "Add New Etd"
      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('span#addfiles') do
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Descriptions" # switch tab

      fill_in('Title', with: 'My Test Work')
      fill_in('Abstract or Summary', with: 'This is an abstract, this abstract is a Description of the project')
      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Contributor', with: 'Robert Brown')
      fill_in('Publisher', with: 'WPI')
      fill_in('Keyword', with: 'testing_keyword')
      fill_in('Subject', with: 'subject_area')
      fill_in('Date Created', with: '1999-09-09')
      fill_in('Degree', with: 'MS')
      fill_in('Department', with: 'ECE')
      select('In Copyright', from: 'Rights statement')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('etd_visibility_open')
      check('agreement')

      click_on('Save')
      click_on('Go')
      results = page.find('div', :id => 'search-results')
      div = results.find('div', :class => 'metadata')
      dl = div.find('dl', :class => 'dl-horizontal')

      expect(dl).to have_content 'Date Created'
      expect(dl).to have_content('Description' )
      expect(dl).to have_content('Creator')
      expect(dl).to have_content('Contributor')
      expect(dl).to have_content('Publisher')
      expect(dl).to have_content('Keyword')
      expect(dl).not_to have_content('Subject')
      expect(dl).to have_content('Date')
      expect(dl).to have_content('Degree')
      expect(dl).to have_content('Department')

    end
  end
end