class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :email
      t.string :phone_number
      t.string :first_name
      t.string :last_name
      t.string :vit_number
      t.integer :user_id
      t.string :abn_number

      t.timestamps null: false
    end
  end
end
