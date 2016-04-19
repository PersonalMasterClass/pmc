class AddUserIdToPresenters < ActiveRecord::Migration
  def change
    add_column :presenters, :user_id, :integer
    add_index :presenters, :user_id
  end
end
