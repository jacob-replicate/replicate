FactoryBot.define do
  factory :user do
    email { "user@example.com" }
    name { "Sample User" }
    encrypted_password { "encrypted" }
    sign_in_count { 1 }
  end
end
