class AddDeletedAtToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :deleted_at, :datetime
    add_index :bookings, :deleted_at
  end
end
