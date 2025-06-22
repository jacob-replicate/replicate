class User < ApplicationRecord
  devise :database_authenticatable, :lockable, :registerable, :recoverable, :validatable
end
