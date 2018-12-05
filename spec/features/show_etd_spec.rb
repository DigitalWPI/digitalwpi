# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Display an Etd work' do

  before do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
  end

  let(:title) { ['Example title'] }
  let(:creator) { ['Doe, Jane'] }
  let(:keyword) { ['hello world'] }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:user) { 'test@example.com' }
  let(:alternate_title) { ['Example Alternate Title'] }
  let(:identifier) { ['ETD-987654-734567'] }
  let(:award) { ['Best Dissertation of the Year'] }
  let(:includes) { ['This work also includes a rails application.'] }
  let(:advisor) { ['Hawking, Stephen'] }
  let(:orcid) { ['09876-98765-98765'] }
  let(:committee) { ['Cooper, Sheldon'] }
  let(:degree) { 'MS' }
  let(:department) { ['CS'] }
  let(:school) { ['School of Engineering'] }
  let(:defense_date) { '2018-12-25' }
  let(:year) { '2018' }
  let(:center) { ['Bangkok, Thailand Project Center'] }
  let(:funding) { ['National Science Foundation'] }
  let(:sponsor) { ['Musk, Elon'] }
  let(:institute) { ['Thailand Research Institute'] }

  let :etd do
    Etd.create(
      title: title,
      creator: creator,
      keyword: keyword,
      visibility: visibility,
      depositor: user,
      alternate_title: alternate_title,
      identifier: identifier,
      award: award,
      includes: includes,
      advisor: advisor,
      orcid: orcid,
      degree: degree,
      department: department,
      school: school,
      defense_date: defense_date,
      year: year,
      center: center,
      funding: funding,
      sponsor: sponsor,
      institute: institute
    )
  end

  scenario 'Show an Etd work' do
    visit("concern/etds/#{etd.id}")

    expect(page).to have_content etd.title.first
    expect(page).to have_content etd.creator.first
    expect(page).to have_content etd.keyword.first
    expect(page).to have_content etd.alternate_title.first
    expect(page).to have_content etd.identifier.first
    expect(page).to have_content etd.award.first
    expect(page).to have_content etd.includes.first
    expect(page).to have_content etd.advisor.first
    expect(page).to have_content etd.orcid.first
    expect(page).to have_content etd.degree.first
    expect(page).to have_content etd.department.first
    expect(page).to have_content etd.school.first
    expect(page).to have_content etd.defense_date.first
    expect(page).to have_content etd.year.first
    expect(page).to have_content etd.center.first
    expect(page).to have_content etd.funding.first
    expect(page).to have_content etd.sponsor.first
    expect(page).to have_content etd.institute.first
  end
end
