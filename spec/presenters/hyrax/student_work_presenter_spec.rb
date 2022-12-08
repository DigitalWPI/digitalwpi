# Generated via
#  `rails generate hyrax:work StudentWork`
require 'rails_helper'

RSpec.describe Hyrax::StudentWorkPresenter do
  subject { presenter }

  before do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
  end

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
  let(:editorial_note) { 'My editorial note' }

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
      editorial_note: editorial_note
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
  it "delegates editorial_note to solr document" do
    expect(solr_document).to receive(:editorial_note)
    presenter.editorial_note
  end

  describe '#export' do
    let(:host) { double(host: 'http://example.org') }
    let(:user) { nil }
    let(:presenter) { described_class.new(solr_document, Ability.new(user), host) }

    describe "export as ttl" do
      subject { presenter.export_as_ttl }
      let(:model_regex)          { %r(<info:fedora/fedora-system:def/model#hasModel> "StudentWork")}
      let(:editorial_note_regex) { %r(<http://www.w3.org/2004/02/skos/core#editorialNote> "My editorial note") }

      it "should have model triple" do
        is_expected.to match(model_regex)
      end
      it "should not have editorial note triple" do
        is_expected.not_to match(editorial_note_regex)
      end
    end

    describe "export as nt" do
      subject { presenter.export_as_nt }
      let(:model_regex)          { %r(<http://example.org/concern/student_works/#{student_work.id}> <info:fedora/fedora-system:def/model#hasModel> "StudentWork" )}
      let(:editorial_note_regex) { %r(<http://example.org/concern/student_works/#{student_work.id}> <http://www.w3.org/2004/02/skos/core#editorialNote> "My editorial note") }
      it "should have model triple" do
        is_expected.to match(model_regex)
      end
      it "should not have editorial note triple" do
        is_expected.not_to match(editorial_note_regex)
      end
    end

    describe '#export_as_jsonld' do
      subject { JSON.parse(presenter.export_as_jsonld) }
      it "should have model" do
        expect(subject["@context"]).to include(
                                         "pcdmterms" => "http://pcdm.org/models#",
                                         "worksterms" => "http://projecthydra.org/works/models#",
                                         "dc" => "http://purl.org/dc/terms/",
                                         "acl" => "http://www.w3.org/ns/auth/acl#",
                                         "system" => "info:fedora/fedora-system:",
                                         "model" => "system:def/model#"
                                       )
        expect(subject["model:hasModel"]).to eql "StudentWork"
      end
      it "should not have editorial note triple" do
        is_expected.not_to include("skos:editorialNote" => "My editorial note")
      end
    end
  end
end

