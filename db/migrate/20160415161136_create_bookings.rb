class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :customer_id
      t.integer :presenter_id
      t.datetime :booking_date
      t.integer :duration_minutes
      t.string :cancellation_message
      t.boolean :shared, :default => false
      t.integer :approval
      t.integer :subject_id
      t.boolean :presenter_paid, :default => false
      t.references :chosen_presenter, index: true
      t.references :creator, index: true

      t.timestamps null: false
    end
  end
end
