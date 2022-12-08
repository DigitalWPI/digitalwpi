# Generated via
#  `rails generate hyrax:work GenericWork`
require 'rails_helper'

RSpec.describe GenericWork do
  describe '#alternate_title' do
    context 'with a new Generic Work' do
      it "has no alternate title when first created" do
        generic_work = described_class.new
        expect(generic_work.alternate_title).to eq([])
      end
    end
  end
  describe '#alternate_title' do
    context 'with a new Generic Work' do
      it "can assign and retrieve the alternate title of Generic Work works" do
        generic_work = described_class.new
        generic_work.alternate_title = ["Alternate Title for My Work"]
        expect(generic_work.alternate_title).to eq(["Alternate Title for My Work"])
      end
    end
  end
  describe '#award' do
    context 'with a new Generic Work' do
      it "has no award when first created" do
        generic_work = described_class.new
        expect(generic_work.award).to eq([])
      end
    end
  end
  describe '#award' do
    context 'with a new Generic Work' do
      it "can assign and retrieve the award of Generic Work works" do
        generic_work = described_class.new
        generic_work.award = ["Best Dissertation of the Year"]
        expect(generic_work.award).to eq(["Best Dissertation of the Year"])
      end
    end
  end
  describe '#includes' do
    context 'with a new Generic Work' do
      it "has no includes when first created" do
        generic_work = described_class.new
        expect(generic_work.includes).to eq([])
      end
    end
  end
  describe '#includes' do
    context 'with a new Generic Work' do
      it "can assign and retrieve includes of Generic Work works" do
        generic_work = described_class.new
        generic_work.includes = ["Dissertation includes a dataset containing the oldest human genome"]
        expect(generic_work.includes).to eq(["Dissertation includes a dataset containing the oldest human genome"])
      end
    end
  end
  describe '#digitization_date' do
    context 'with a new Generic Work' do
      it "has no advisor when first created" do
        generic_work = described_class.new
        expect(generic_work.digitization_date).to eq(nil)
      end
    end
  end
  describe '#digitization_date' do
    context 'with a new Generic Work' do
      it "can assign and retrieve an digitization date of Generic Work works" do
        generic_work = described_class.new
        generic_work.digitization_date = "2018-12-25"
        expect(generic_work.digitization_date).to eq("2018-12-25")
      end
    end
  end
  describe '#series' do
    context 'with a new Generic Work' do
      it "has no series when first created" do
        generic_work = described_class.new
        expect(generic_work.series).to eq([])
      end
    end
  end
  describe '#series' do
    context 'with a new Generic Work' do
      it "can assign and retrieve series of Generic Work works" do
        generic_work = described_class.new
        generic_work.series = ["David Lucht"]
        expect(generic_work.series).to eq(["David Lucht"])
      end
    end
  end
  describe '#event' do
    context 'with a new Generic Work' do
      it "has no event when first created" do
        generic_work = described_class.new
        expect(generic_work.event).to eq([])
      end
    end
  end
  describe '#event' do
    context 'with a new Generic Work' do
      it "can assign and retrieve event of Generic Work works" do
        generic_work = described_class.new
        generic_work.event = ["10th Anniversary"]
        expect(generic_work.event).to eq(["10th Anniversary"])
      end
    end
  end
  describe '#year' do
    context 'with a new Generic Work' do
      it "has no year when first created" do
        generic_work = described_class.new
        expect(generic_work.year).to eq(nil)
      end
    end
  end
  describe '#year' do
    context 'with a new Generic Work' do
      it "can assign and retrieve year of Generic Work works" do
        generic_work = described_class.new
        generic_work.year = 2018
        expect(generic_work.year).to eq(2018)
      end
    end
  end
  describe '#extent' do
    context 'with a new Generic Work' do
      it "has no extent when first created" do
        generic_work = described_class.new
        expect(generic_work.extent).to eq([])
      end
    end
  end
  describe '#extent' do
    context 'with a new Generic Work' do
      it "can assign and retrieve extent of Generic Work works" do
        generic_work = described_class.new
        generic_work.extent = ["Some random size of the resource"]
        expect(generic_work.extent).to eq(["Some random size of the resource"])
      end
    end
  end
  describe '#school' do
    context 'with a new Generic Work' do
      it "has no school when first created" do
        generic_work = described_class.new
        expect(generic_work.school).to eq([])
      end
    end
  end
  describe '#school' do
    context 'with a new Generic Work' do
      it "can assign and retrieve the school of Generic Work works" do
        generic_work = described_class.new
        generic_work.school = ["School of Arts"]
        expect(generic_work.school).to eq(["School of Arts"])
      end
    end
  end
  describe '#editorial_note' do
    context 'with a new Generic Work' do
      it "can assign and retrieve the admin note of Generic Work works" do
        generic_work = described_class.new
        generic_work.editorial_note = "My note"
        expect(generic_work.editorial_note).to eq('My note')
      end
    end
  end
end
