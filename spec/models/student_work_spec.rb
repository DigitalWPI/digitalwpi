# Generated via
#  `rails generate hyrax:work StudentWork`
require 'rails_helper'

RSpec.describe StudentWork do
  describe '#alternate_title' do
    context 'with a new Student Work' do
      it "has no alternate title when first created" do
        student_work = described_class.new
        expect(student_work.alternate_title).to eq([])
      end
    end
  end
  describe '#alternate_title' do
    context 'with a new Student Work' do
      it "can assign and retrieve the alternate title of Student Work works" do
        student_work = described_class.new
        student_work.alternate_title = ["Alternate Title for My Work"]
        expect(student_work.alternate_title).to eq(["Alternate Title for My Work"])
      end
    end
  end
  describe '#award' do
    context 'with a new Student Work' do
      it "has no award when first created" do
        student_work = described_class.new
        expect(student_work.award).to eq([])
      end
    end
  end
  describe '#award' do
    context 'with a new Student Work' do
      it "can assign and retrieve the award of Student Work works" do
        student_work = described_class.new
        student_work.award = ["Best Dissertation of the Year"]
        expect(student_work.award).to eq(["Best Dissertation of the Year"])
      end
    end
  end
  describe '#includes' do
    context 'with a new Student Work' do
      it "has no includes when first created" do
        student_work = described_class.new
        expect(student_work.includes).to eq([])
      end
    end
  end
  describe '#includes' do
    context 'with a new Student Work' do
      it "can assign and retrieve includes of Student Work works" do
        student_work = described_class.new
        student_work.includes = ["Dissertation includes a dataset containing the oldest human genome"]
        expect(student_work.includes).to eq(["Dissertation includes a dataset containing the oldest human genome"])
      end
    end
  end
  describe '#advisor' do
    context 'with a new Student Work' do
      it "has no advisor when first created" do
        student_work = described_class.new
        expect(student_work.advisor).to eq([])
      end
    end
  end
  describe '#advisor' do
    context 'with a new Student Work' do
      it "can assign and retrieve an advisor of Student Work works" do
        student_work = described_class.new
        student_work.advisor = ["Proton, Professor"]
        expect(student_work.advisor).to eq(["Proton, Professor"])
      end
    end
  end
  describe '#sponsor' do
    context 'with a new Student Work' do
      it "has no sponsor when first created" do
        student_work = described_class.new
        expect(student_work.sponsor).to eq([])
      end
    end
  end
  describe '#sponsor' do
    context 'with a new Student Work' do
      it "can assign and retrieve sponsor of Student Work works" do
        student_work = described_class.new
        student_work.sponsor = ["Musk, Elon"]
        expect(student_work.sponsor).to eq(["Musk, Elon"])
      end
    end
  end
  describe '#center' do
    context 'with a new Student Work' do
      it "has no center when first created" do
        student_work = described_class.new
        expect(student_work.center).to eq([])
      end
    end
  end
  describe '#center' do
    context 'with a new Student Work' do
      it "can assign and retrieve center of Student Work works" do
        student_work = described_class.new
        student_work.center = ["Bangkok, Thailand Project Center"]
        expect(student_work.center).to eq(["Bangkok, Thailand Project Center"])
      end
    end
  end
  describe '#year' do
    context 'with a new Student Work' do
      it "has no year when first created" do
        student_work = described_class.new
        expect(student_work.year).to eq(nil)
      end
    end
  end
  describe '#year' do
    context 'with a new Student Work' do
      it "can assign and retrieve year of Student Work works" do
        student_work = described_class.new
        student_work.year = 2018
        expect(student_work.year).to eq(2018)
      end
    end
  end
  describe '#funding' do
    context 'with a new Student Work' do
      it "has no funding when first created" do
        student_work = described_class.new
        expect(student_work.funding).to eq([])
      end
    end
  end
  describe '#funding' do
    context 'with a new Student Work' do
      it "can assign and retrieve funding of Student Work works" do
        student_work = described_class.new
        student_work.funding = ["National Science Foundation"]
        expect(student_work.funding).to eq(["National Science Foundation"])
      end
    end
  end
  describe '#institute' do
    context 'with a new Student Work' do
      it "has no institute when first created" do
        student_work = described_class.new
        expect(student_work.institute).to eq([])
      end
    end
  end
  describe '#institute' do
    context 'with a new Student Work' do
      it "can assign and retrieve institute of Student Work works" do
        student_work = described_class.new
        student_work.institute = ["Thailand Research Institute"]
        expect(student_work.institute).to eq(["Thailand Research Institute"])
      end
    end
  end
  describe '#school' do
    context 'with a new Student Work' do
      it "has no school when first created" do
        student_work = described_class.new
        expect(student_work.school).to eq([])
      end
    end
  end
  describe '#school' do
    context 'with a new Student Work' do
      it "can assign and retrieve the school of Student Work works" do
        student_work = described_class.new
        student_work.school = ["School of Arts"]
        expect(student_work.school).to eq(["School of Arts"])
      end
    end
  end
  describe '#major' do
    context 'with a new Student Work' do
      it "has no major when first created" do
        student_work = described_class.new
        expect(student_work.major).to eq([])
      end
    end
  end
  describe '#major' do
    context 'with a new Student Work' do
      it "can assign and retrieve the major of Student Work works" do
        student_work = described_class.new
        student_work.major = ["Theatre"]
        expect(student_work.major).to eq(["Theatre"])
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
