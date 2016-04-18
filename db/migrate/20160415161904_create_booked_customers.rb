class CreateBookedCustomers < ActiveRecord::Migration
  def change
    create_table :booked_customers do |t|
      t.integer :customer_id
      t.integer :booking_id
      t.integer :number_students
      t.boolean :paid, :default => false

      t.timestamps null: false
    end
  end
end
