class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :user_type, :integer
    add_column :users, :status, :integer
  end
end
