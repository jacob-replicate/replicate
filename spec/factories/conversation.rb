FactoryBot.define do
  factory :conversation do
    topic { "dns" }
    template { false }

    trait :template do
      template { true }
    end

    trait :with_session do
      sequence(:session_id) { |n| "session_#{n}" }
    end
  end
end