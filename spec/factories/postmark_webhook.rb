FactoryBot.define do
  factory :postmark_webhook do
    webhook_type { "bounce" }
    content { { "example" => "data" } }
    conversation
    processed_at { nil }
  end
end
