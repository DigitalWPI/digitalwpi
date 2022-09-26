# frozen_string_literal: true
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{FFaker::Internet.user_name}#{n}@wpi.edu" }
    # sequence(:uid) { |n| "#{FFaker::Internet.user_name}#{n}" }
    password { Faker::Internet.password(8).to_s }
    # first_name {"#{Faker::Name.first_name}"}
    # last_name {"#{Faker::Dog.breed}"}
  end
  factory :admin_user do
	sequence(:email) { |n| "#{FFaker::Internet.user_name}#{n}@wpi.edu" }
    # sequence(:uid) { |n| "#{FFaker::Internet.user_name}#{n}" }
    password { Faker::Internet.password(8).to_s }
    # first_name {"#{Faker::Name.first_name}"}
    # last_name {"#{Faker::Dog.breed}"}  	

  end
end
