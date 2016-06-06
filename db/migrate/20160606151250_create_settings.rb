class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.boolean :booking, default: true
      t.boolean :enquiry, default: true
      t.boolean :system, default: true
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :settings, :user_id
  end
end
