# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Etd do
  describe '#degree' do
    context 'with a new ETD' do
      it "has no degree when first created" do
      	etd = Etd.new()
      	expect(etd.degree).to be_empty
      end
    end
  end
  describe '#department' do
    context 'with a new ETD' do 
      it "has no department when first created" do
      	etd = Etd.new()
      	expect(etd.department).to be_empty
      end
  	end
  end
   describe '#degree' do
    context 'with a new ETD' do
      it "can assign and retrieve the degree of ETD works" do
      	etd = Etd.new()
      	etd.degree = ["MS"]
      	expect(etd.degree).to eq(["MS"])
      end
    end
  end
  describe '#department' do
    context 'with a new ETD' do 
      it "has no department when first created" do
      	etd = Etd.new()
      	etd.department = ["ECE"]
      	expect(etd.department).to eq(["ECE"])
      end
  	end
  end
end
