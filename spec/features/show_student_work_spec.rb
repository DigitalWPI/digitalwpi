require 'rails_helper'

RSpec.feature 'Display an Student Work work' do
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
  let(:sponsor) { ['Musk, Elon'] }
  let(:center) { ['Bangkok, Thailand Project Center'] }
  let(:year) { '2018' }
  let(:funding) { ['National Science Foundation'] }
  let(:institute) { ['Thailand Research Institute'] }
  let(:school) { ['School of Engineering'] }
  let(:major) { ['Theatre'] }

  let :student_work do
    StudentWork.create(
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
      sponsor: sponsor,
      center: center,
      year: year,
      funding: funding,
      institute: institute,
      school: school,
      major: major
    )
  end

  scenario 'Show a Student Work work' do
    visit("concern/student_works/#{student_work.id}")

    expect(page).to have_content student_work.title.first
    expect(page).to have_content student_work.creator.first
    expect(page).to have_content student_work.keyword.first
    expect(page).to have_content student_work.alternate_title.first
    expect(page).to have_content student_work.identifier.first
    expect(page).to have_content student_work.award.first
    expect(page).to have_content student_work.includes.first
    expect(page).to have_content student_work.advisor.first
    expect(page).to have_content student_work.sponsor.first
    expect(page).to have_content student_work.center.first
    expect(page).to have_content student_work.year.first
    expect(page).to have_content student_work.funding.first
    expect(page).to have_content student_work.institute.first
    expect(page).to have_content student_work.school.first
    expect(page).to have_content student_work.major.first
  end
end
