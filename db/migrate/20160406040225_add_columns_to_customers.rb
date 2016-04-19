class AddColumnsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :department, :string
    add_column :customers, :contact_title, :string
  end
end
