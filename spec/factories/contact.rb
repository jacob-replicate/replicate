FactoryBot.define do
  factory :contact do
    cohort { "Q1" }
    company_domain { "example.com" }
    contacted_at { nil }
    email { "contact@example.com" }
    external_id { SecureRandom.uuid }
    location { "USA" }
    name { "John Doe" }
    score { 80 }
    score_reason { "High intent" }
    source { "manual" }
    state { "Virginia" }
    unsubscribed { false }
  end
end