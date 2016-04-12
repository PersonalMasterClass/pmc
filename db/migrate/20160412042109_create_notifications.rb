class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.boolean :is_read
      t.string :reference
      t.string :message
      t.int :user_id

      t.timestamps null: false
    end
  end
end

