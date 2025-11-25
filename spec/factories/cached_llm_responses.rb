FactoryBot.define do
  factory :cached_llm_response do
    input_hash { "MyText" }
    response { "MyText" }
  end
end
