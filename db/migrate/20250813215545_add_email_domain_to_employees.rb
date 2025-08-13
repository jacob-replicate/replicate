class AddEmailDomainToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :email_domain, :string
  end
end