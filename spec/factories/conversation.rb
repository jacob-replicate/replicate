FactoryBot.define do
  factory :conversation do
    variant { "incident" }
    channel { "web" }
    state { "pending" }
    template { false }
    sequence(:code) { |n| "conversation-#{n}" }
    sequence(:name) { |n| "Test Conversation #{n}" }
    description { "A test conversation description" }

    trait :template do
      template { true }
    end

    trait :populated do
      state { "populated" }
    end

    trait :owned_by_session do
      owner_type { "Session" }
      sequence(:owner_id) { |n| "session_#{n}" }
    end

    trait :owned_by_user do
      owner_type { "User" }
      association :owner, factory: :user
    end
  end
end