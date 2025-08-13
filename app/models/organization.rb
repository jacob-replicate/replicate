class Organization < ApplicationRecord
  has_many :members, dependent: :destroy
end