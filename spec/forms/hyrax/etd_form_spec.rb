# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'


RSpec.describe Hyrax::EtdForm do
  subject { form }
  let(:etd) { Etd.new }
  let(:ability) { Ability.new(nil) }
  let(:request) { nil }
  let(:form)    { described_class.new(etd, ability, request) }
  it "has the expected terms" do
    expect(form.terms).to include(:degree)
    expect(form.terms).to include(:department)
    expect(form.terms).to include(:school)
    expect(form.terms).to include(:alternate_title)
    expect(form.terms).to include(:award)
    expect(form.terms).to include(:includes)
    expect(form.terms).to include(:advisor)
    expect(form.terms).to include(:orcid)
    expect(form.terms).to include(:committee)
    expect(form.terms).to include(:defense_date)
    expect(form.terms).to include(:year)
    expect(form.terms).to include(:center)
    expect(form.terms).to include(:funding)
    expect(form.terms).to include(:sponsor)
    expect(form.terms).to include(:institute)
    expect(form.terms).to include(:editorial_note)
  end
end
