# frozen_string_literal: true
# taken from hyrax 7.1
FactoryBot.define do
  factory :generic_work, aliases: [:work, :private_generic_work], class: 'GenericWork' do
    transient do
      user { FactoryBot.create(:user) }
    end

    title { ["Test title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :public_generic_work, aliases: [:public_work] do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    factory :registered_generic_work do
      read_groups { ["registered"] }
    end

    factory :generic_work_with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryBot.create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], label: 'filename.pdf')
      end
    end

    factory :embargoed_generic_work do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      visibility_after_embargo { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    end

    factory :work_with_representative_file do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryBot.create(:file_set, user: evaluator.user, title: ['A Contained FileSet'])
        work.representative_id = work.members[0].id
      end
    end

    trait :with_public_embargo do
      after(:build) do |work, evaluator|
        work.embargo = FactoryBot.create(:public_embargo, embargo_release_date: evaluator.embargo_release_date)
      end
    end

    trait :with_editorial_note do
      editorial_note { 'First edit of work' }
    end
  end
end
