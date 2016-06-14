class AddAccountingRefToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :accounting_ref, :string
  end
end
