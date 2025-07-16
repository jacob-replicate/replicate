class Organization < ApplicationRecord
  has_many :employees, dependent: :destroy
end