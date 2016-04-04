class CreatePresenters < ActiveRecord::Migration
  def change
    create_table :presenters do |t|
      t.string :email
      t.string :phone_number
      t.string :first_name
      t.string :last_name
      t.string :vit_number
      t.string :abn_number
      t.integer :school_id
      t.timestamps null: false
    end
  end
end
