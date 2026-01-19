FactoryBot.define do
  factory :topic do
    sequence(:code) { |n| "topic-#{n}" }
    name { "MyText" }
    description { "MyText" }
    generation_intent { "MyText" }
  end
end