class AddTechStackScrapingConsentToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :tech_stack_scraping_consent, :boolean, default: false, null: false
  end
end