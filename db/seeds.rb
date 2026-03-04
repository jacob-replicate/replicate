# frozen_string_literal: true

# Load all seed files from db/seeds/
Dir[Rails.root.join("db/seeds/*.rb")].sort.each do |seed_file|
  load seed_file
end