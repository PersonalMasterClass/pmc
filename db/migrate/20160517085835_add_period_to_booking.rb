class AddPeriodToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :period, :integer
  end
end
