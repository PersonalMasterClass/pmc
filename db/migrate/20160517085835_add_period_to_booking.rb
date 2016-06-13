class AddPeriodToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :period, :integer, default: 2
  end
end
