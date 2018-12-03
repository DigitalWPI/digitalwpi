# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Display an Generic Work work' do

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
  let(:digitization_date) { '2018-12-25' }
  let(:series) { ['David Lucht'] }
  let(:event) { ['12th Anniversary'] }
  let(:year) { '2018' }
  let(:extent) { ['4:20 mins'] }
  let(:school) { ['School of Engineering'] }

  let :generic_work do
    GenericWork.create(
      title: title,
      creator: creator,
      keyword: keyword,
      visibility: visibility,
      depositor: user,
      alternate_title: alternate_title,
      identifier: identifier,
      award: award,
      includes: includes,
      digitization_date: digitization_date,
      series: series,
      event: event,
      year: year,
      extent: extent,
      school: school
    )
  end

  scenario 'Show a Generic Work work' do
    visit("concern/generic_works/#{generic_work.id}")
    expect(page).to have_content generic_work.title.first
    expect(page).to have_content generic_work.creator.first
    expect(page).to have_content generic_work.keyword.first
    expect(page).to have_content generic_work.alternate_title.first
    expect(page).to have_content generic_work.identifier.first
    expect(page).to have_content generic_work.award.first
    expect(page).to have_content generic_work.includes.first
    expect(page).to have_content generic_work.digitization_date
    expect(page).to have_content generic_work.series.first
    expect(page).to have_content generic_work.event.first
    expect(page).to have_content generic_work.year.first
    expect(page).to have_content generic_work.extent.first
    expect(page).to have_content generic_work.school.first
  end
end
