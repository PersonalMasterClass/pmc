class CreateSubscription < ActiveRecord::Migration
  def change
    create_table :customers_subjects do |t|
      t.integer :customer_id
      t.integer :subject_id
    end
    add_index :customers_subjects, :customer_id
    add_index :customers_subjects, :subject_id
  end
end
