class DropCareerScrapingConsent < ActiveRecord::Migration[7.1]
  def change
    remove_column :organizations, :tech_stack_scraping_consent
  end
end