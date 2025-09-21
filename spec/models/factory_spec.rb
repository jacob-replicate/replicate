require 'rails_helper'

RSpec.describe 'FactoryBot' do
  it 'has valid factories' do
    begin
      FactoryBot.lint
    rescue FactoryBot::InvalidFactoryError => e
      fail "Invalid factory detected: #{e.message}"
    end
  end
end