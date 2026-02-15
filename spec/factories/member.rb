FactoryBot.define do
  factory :member do
    association :organization
    name { "Alice Smith" }
    sequence(:email) { |n| "employee#{n}@invariant.training" }
    role { "engineer" }
    subscribed { true }
    email_bounced { false }
  end
end