FactoryBot.define do
  factory :message do
    association :conversation
    content { "Example content" }
    user_generated { true }
  end
end
