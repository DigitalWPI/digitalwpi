# frozen_string_literal: true
FactoryBot.define do
  factory :student_work, aliases: [:private_student_work], class: 'StudentWork' do
    transient do
      user { FactoryBot.create(:user) }
    end

    title do ["Test title"] end
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :public_student_work do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    factory :registered_student_work do
      read_groups { ["registered"] }
    end

    factory :student_work_with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryBot.create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], label: 'filename.pdf')
      end
    end
    factory :public_student_work_in_colleciton do
      before(:create) do |collection|
        work.member_of_collections << collection
      end
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end
  end
end