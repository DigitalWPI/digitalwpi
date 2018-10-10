require 'rails_helper'

RSpec.feature 'Display an Etd work' do
	let(:title) { ['Example title'] }
	let(:creator) { ['Doe, Jane'] }
	let(:keyword) { ['hello world'] }
	let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
	let(:user) { 'test@example.com' }
	let(:degree) { 'MS' }
	let(:department) { ['CS'] }

	let :etd do
		Etd.create(
			title: title,
			creator: creator,
			keyword: keyword,
			visibility: visibility,
			depositor: user,
			degree: degree,
			department: department
		)
	end

	scenario 'Show an Etd work' do
		visit("concern/etds/#{etd.id}")

		expect(page).to have_content etd.title.first
		expect(page).to have_content etd.creator.first
		expect(page).to have_content etd.keyword.first
		expect(page).to have_content etd.degree.first
		expect(page).to have_content etd.department.first
	end
end
