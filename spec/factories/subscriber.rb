FactoryBot.define do
  factory :subscriber do
    email { "subscriber@example.com" }
    subscribed { true }
  end
end
