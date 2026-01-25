class User < ApplicationRecord
  validates :provider, :uid, :email, presence: true
  validates :uid, uniqueness: { scope: :provider }

  def admin?
    admin == true
  end
end