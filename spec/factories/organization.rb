FactoryBot.define do
  factory :organization do
    name { "Acme Inc" }
    access_end_date { 3.months.from_now }
    flagged { false }
  end
end
