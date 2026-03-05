FactoryBot.define do
  factory :message_component do
    association :message
    sequence(:position) { |n| n }
    data { { "type" => "text", "content" => "Hello world" } }
  end
end