FactoryBot.define do
  factory :missive_webhook do
    webhook_type { "MyString" }
    content { { fizz: "buzz" } }
    processed_at { "2025-09-22 21:31:23" }
  end
end