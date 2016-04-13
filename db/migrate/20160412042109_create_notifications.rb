class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.boolean :is_read, :default => false
      t.string :reference
      t.string :message
      t.integer :user_id

      t.timestamps null: false
    end
  end
end

