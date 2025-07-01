class User < ApplicationRecord
  devise :database_authenticatable, :lockable, :registerable, :recoverable, :validatable
  has_many :conversations, as: :recipient, dependent: :destroy
end