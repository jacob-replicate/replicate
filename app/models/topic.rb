class Topic < ApplicationRecord
  has_many :experiences, dependent: :destroy
  validates :name, :description, presence: true
end