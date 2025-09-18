FactoryBot.define do
  factory :conversation do
    recipient { association(:member) }
    channel { "email" }
    context { {} }
  end
end