FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    sequence(:uid) { |n| "uid_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    avatar_url { "https://example.com/avatar.png" }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end