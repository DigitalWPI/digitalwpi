# Generated via
#  `rails generate hyrax:work StudentWork`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a StudentWork', js: true do


  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do

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
      studentwork_permission_role = Role.create(name: "StudentWork_permission")
      studentwork_permission_role.users << user
      login_as user
    end

    scenario do
      # visit '/concern/student_works/new'  # KTODO original project use this url

      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      choose "payload_concern", option: "StudentWork"
      click_button "Create work"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('div#add-files') do
        attach_file("files[]", "#{fixture_path}/flower.jpg", visible: false)
      end
      click_link "Descriptions" # switch tab
      click_link "Additional fields"
      fill_in('Title', with: 'My Test Work')
      fill_in('Creator', with: 'Doe, Jane')
      select('In Copyright', from: 'Rights statement')
      
      fill_in('Keyword', with: 'testing')

      fill_in("Identifier", with: "eir-9876-9878")
      fill_in("Alternate title", with: "Alternate title for my work")
      fill_in("Award", with: "Best Dissertation of the Year")
      fill_in("Includes", with: "This work also includes a rails application as part of this dissertation.")
      fill_in("Faculty Advisor", with: "Me, Not")
      fill_in("Sponsor", with: "Musk, Elon")
      fill_in("Center", with: "Bangkok, Thailand Project Center")
      fill_in("Year", with: "2018")
      fill_in("Funding Organization", with: "National Science Foundation")
      fill_in("Institute", with: "Thailand Research Institute")
      fill_in("School", with: "School of Arts")
      fill_in("Major", with: "Theatre")

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('student_work_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')

      click_button('Save')
      expect(page).to have_content('My Test Work')
      # expect(page).to have_content "Your files are being processed by Hyrax in the background."
    end
  end
end
