FactoryBot.define do
  factory :contact do
    cohort { "Q1" }
    company_domain { "example.com" }
    contacted_at { nil }
    sequence(:email) { |i| "alex-#{i}@example.com" }
    external_id { SecureRandom.uuid }
    location { "USA" }
    sequence(:name) { |i| "Alex ##{i}" }
    score { 80 }
    score_reason { "High intent" }
    source { "manual" }
    state { "Virginia" }
    unsubscribed { false }
  end
end