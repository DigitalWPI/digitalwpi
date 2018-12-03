# Generated via
#  `rails generate hyrax:work GenericWork`
require 'rails_helper'

RSpec.describe Hyrax::GenericWorkForm do
  subject { form }
  let(:generic_work)    { GenericWork.new }
  let(:ability) { Ability.new(nil) }
  let(:request) { nil }
  let(:form)    { described_class.new(generic_work, ability, request) }
  it "has the expected terms" do
    expect(form.terms).to include(:alternate_title)
    expect(form.terms).to include(:award)
    expect(form.terms).to include(:includes)
    expect(form.terms).to include(:digitization_date)
    expect(form.terms).to include(:series)
    expect(form.terms).to include(:event)
    expect(form.terms).to include(:year)
    expect(form.terms).to include(:extent)
    expect(form.terms).to include(:school)
  end
end
