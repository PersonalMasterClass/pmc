class CreateEnquiriesTable < ActiveRecord::Migration
  def change
    create_table :enquiries do |t|
      t.integer :customer_id
      t.integer :presenter_id
      t.integer :from
      t.date :date
      t.time :time
      t.integer :rate
      t.integer :status, default: 0
      t.timestamps :created_at
    end
    add_index :enquiries, :customer_id
    add_index :enquiries, :presenter_id
  end
end
