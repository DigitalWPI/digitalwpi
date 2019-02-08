# frozen_string_literal: true
FactoryBot.define do
  factory :collection do
    transient do
      user { FactoryBot.create(:user) }
    end
    sequence(:title) { |n| ["Title #{n}"] }
    before(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :public_collection, traits: [:public]

    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    factory :private_collection do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    end

    factory :institution_collection do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
    end

    factory :named_collection do
      title { ['collection title'] }
      description { ['collection description'] }
      creator { ['collection creator'] }
    end
  end
end
