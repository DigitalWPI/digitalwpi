# Generated via
#  `rails generate hyrax:work StudentWork`
require 'rails_helper'

RSpec.describe Hyrax::StudentWorkPresenter do
  subject { presenter }

  let(:title) { ['Example title'] }
  let(:creator) { ['Doe, Jane'] }
  let(:keyword) { ['hello world'] }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:user) { 'test@example.com' }
  let(:identifier) { ['ETD-987654-734567'] }
  let(:alternate_title) { ['Example Alternate Title'] }
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
      identifier: identifier,
      alternate_title: alternate_title,
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

  let(:ability) { Ability.new(user) }

  let(:solr_document) { SolrDocument.new(student_work.to_solr) }

  let(:presenter) do
    described_class.new(solr_document, nil)
  end

  it "delegates alternate title to solr document" do
    expect(solr_document).to receive(:alternate_title)
    presenter.alternate_title
  end
  it "delegates award to solr document" do
    expect(solr_document).to receive(:award)
    presenter.award
  end
  it "delegates includes to solr document" do
    expect(solr_document).to receive(:includes)
    presenter.includes
  end
  it "delegates advisor to solr document" do
    expect(solr_document).to receive(:advisor)
    presenter.advisor
  end
  it "delegates sponsor to solr document" do
    expect(solr_document).to receive(:sponsor)
    presenter.sponsor
  end
  it "delegates center to solr document" do
    expect(solr_document).to receive(:center)
    presenter.center
  end
  it "delegates year to solr document" do
    expect(solr_document).to receive(:year)
    presenter.year
  end
  it "delegates funding to solr document" do
    expect(solr_document).to receive(:funding)
    presenter.funding
  end
  it "delegates institute to solr document" do
    expect(solr_document).to receive(:institute)
    presenter.institute
  end
  it "delegates school to solr document" do
    expect(solr_document).to receive(:school)
    presenter.school
  end
  it "delegates major to solr document" do
    expect(solr_document).to receive(:major)
    presenter.major
  end
end
