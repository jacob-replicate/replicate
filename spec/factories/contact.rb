FactoryBot.define do
  factory :contact do
    email { "contact@example.com" }
    location { "USA" }
    company_domain { "example.com" }
    state { "active" }
    source { "manual" }
    external_id { SecureRandom.uuid }
    score { 80 }
    score_reason { "High intent" }
    name { "John Doe" }
    cohort { "Q1" }
    contacted { false }
    unsubscribed { false }
  end
end
