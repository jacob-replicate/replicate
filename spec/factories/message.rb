FactoryBot.define do
  factory :message do
    association :conversation
    sequence(:sequence) { |n| n }
    author_name { "ops-bot" }
    author_avatar { "bot.png" }
    is_system { true }
  end
end