# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work GenericWork`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a GenericWork', js: false do
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
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      permission_role = Role.create(name: "GenericWork_permission")
      permission_role.users << user
      login_as user
    end

    scenario do
      visit '/concern/generic_works/new'

      # If you generate more than one work uncomment these lines
      # choose "payload_concern", option: "GenericWork"
      # click_button "Create work"

      expect(page).to have_content "Add New Generic Work"
      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('span#addfiles') do
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Descriptions" # switch tab
      fill_in('Title', with: 'My Test Work')
      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Keyword', with: 'testing')
      select('In Copyright', from: 'Rights statement')

      click_link "Additional fields"
      fill_in("Identifier", with: "eir-9876-9878")
      fill_in("Alternate title", with: "Alternate title for my work")
      fill_in("Award", with: "Best Dissertation of the Year")
      fill_in("Includes", with: "This work also includes a rails application as part of this dissertation.")
      fill_in("Date of Digitization", with: "2018-12-25")
      fill_in("Series", with: "David Lucht")
      fill_in("Event", with: "10th Anniversary")
      fill_in("Year", with: "2018")
      fill_in("Extent", with: "Some random size of the resource")
      fill_in("School", with: "School of Arts")

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('generic_work_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')

      click_on('Save')
      expect(page).to have_content('My Test Work')
      expect(page).to have_content "Your files are being processed by Digital WPI in the background."
    end
  end
end
