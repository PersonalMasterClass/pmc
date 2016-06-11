class AddCapToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :cap, :integer, :default => 30
  end
end
