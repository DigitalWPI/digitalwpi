# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work StudentWork`
require 'rails_helper'

RSpec.describe Hyrax::StudentWorkForm do
  subject { form }
  let(:student_work) { StudentWork.new }
  let(:ability) { Ability.new(nil) }
  let(:request) { nil }
  let(:form)    { described_class.new(student_work, ability, request) }
  it "has the expected terms" do
    expect(form.terms).to include(:alternate_title)
    expect(form.terms).to include(:award)
    expect(form.terms).to include(:includes)
    expect(form.terms).to include(:advisor)
    expect(form.terms).to include(:sponsor)
    expect(form.terms).to include(:center)
    expect(form.terms).to include(:year)
    expect(form.terms).to include(:funding)
    expect(form.terms).to include(:institute)
    expect(form.terms).to include(:school)
    expect(form.terms).to include(:major)
  end
end
