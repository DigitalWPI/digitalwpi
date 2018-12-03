# Generated via
#  `rails generate hyrax:work StudentWork`
require 'rails_helper'

RSpec.describe StudentWork do
  describe '#alternate_title' do
    context 'with a new ETD' do
      it "has no alternate title when first created" do
        etd = described_class.new
        expect(etd.alternate_title).to eq([])
      end
    end
  end
  describe '#alternate_title' do
    context 'with a new ETD' do
      it "can assign and retrieve the alternate title of ETD works" do
        etd = described_class.new
        etd.alternate_title = ["Alternate Title for My Work"]
        expect(etd.alternate_title).to eq(["Alternate Title for My Work"])
      end
    end
  end
  describe '#award' do
    context 'with a new ETD' do
      it "has no award when first created" do
        etd = described_class.new
        expect(etd.award).to eq([])
      end
    end
  end
  describe '#award' do
    context 'with a new ETD' do
      it "can assign and retrieve the award of ETD works" do
        etd = described_class.new
        etd.award = ["Best Dissertation of the Year"]
        expect(etd.award).to eq(["Best Dissertation of the Year"])
      end
    end
  end
  describe '#includes' do
    context 'with a new ETD' do
      it "has no includes when first created" do
        etd = described_class.new
        expect(etd.includes).to eq([])
      end
    end
  end
  describe '#includes' do
    context 'with a new ETD' do
      it "can assign and retrieve includes of ETD works" do
        etd = described_class.new
        etd.includes = ["Dissertation includes a dataset containing the oldest human genome"]
        expect(etd.includes).to eq(["Dissertation includes a dataset containing the oldest human genome"])
      end
    end
  end
  describe '#advisor' do
    context 'with a new ETD' do
      it "has no advisor when first created" do
        etd = described_class.new
        expect(etd.advisor).to eq([])
      end
    end
  end
  describe '#advisor' do
    context 'with a new ETD' do
      it "can assign and retrieve an advisor of ETD works" do
        etd = described_class.new
        etd.advisor = ["Proton, Professor"]
        expect(etd.advisor).to eq(["Proton, Professor"])
      end
    end
  end
  describe '#sponsor' do
    context 'with a new ETD' do
      it "has no sponsor when first created" do
        etd = described_class.new
        expect(etd.sponsor).to eq([])
      end
    end
  end
  describe '#sponsor' do
    context 'with a new ETD' do
      it "can assign and retrieve sponsor of ETD works" do
        etd = described_class.new
        etd.sponsor = ["Musk, Elon"]
        expect(etd.sponsor).to eq(["Musk, Elon"])
      end
    end
  end
  describe '#center' do
    context 'with a new ETD' do
      it "has no center when first created" do
        etd = described_class.new
        expect(etd.center).to eq([])
      end
    end
  end
  describe '#center' do
    context 'with a new ETD' do
      it "can assign and retrieve center of ETD works" do
        etd = described_class.new
        etd.center = ["Bangkok, Thailand Project Center"]
        expect(etd.center).to eq(["Bangkok, Thailand Project Center"])
      end
    end
  end
  describe '#year' do
    context 'with a new ETD' do
      it "has no year when first created" do
        etd = described_class.new
        expect(etd.year).to eq(nil)
      end
    end
  end
  describe '#year' do
    context 'with a new ETD' do
      it "can assign and retrieve year of ETD works" do
        etd = described_class.new
        etd.year = 2018
        expect(etd.year).to eq(2018)
      end
    end
  end
  describe '#funding' do
    context 'with a new ETD' do
      it "has no funding when first created" do
        etd = described_class.new
        expect(etd.funding).to eq([])
      end
    end
  end
  describe '#funding' do
    context 'with a new ETD' do
      it "can assign and retrieve funding of ETD works" do
        etd = described_class.new
        etd.funding = ["National Science Foundation"]
        expect(etd.funding).to eq(["National Science Foundation"])
      end
    end
  end
  describe '#institute' do
    context 'with a new ETD' do
      it "has no institute when first created" do
        etd = described_class.new
        expect(etd.institute).to eq([])
      end
    end
  end
  describe '#institute' do
    context 'with a new ETD' do
      it "can assign and retrieve institute of ETD works" do
        etd = described_class.new
        etd.institute = ["Thailand Research Institute"]
        expect(etd.institute).to eq(["Thailand Research Institute"])
      end
    end
  end
  describe '#school' do
    context 'with a new ETD' do
      it "has no school when first created" do
        etd = described_class.new
        expect(etd.school).to eq([])
      end
    end
  end
  describe '#school' do
    context 'with a new ETD' do
      it "can assign and retrieve the school of ETD works" do
        etd = described_class.new
        etd.school = ["School of Arts"]
        expect(etd.school).to eq(["School of Arts"])
      end
    end
  end
  describe '#major' do
    context 'with a new ETD' do
      it "has no major when first created" do
        etd = described_class.new
        expect(etd.major).to eq([])
      end
    end
  end
  describe '#major' do
    context 'with a new ETD' do
      it "can assign and retrieve the major of ETD works" do
        etd = described_class.new
        etd.major = ["Theatre"]
        expect(etd.major).to eq(["Theatre"])
      end
    end
  end
end
