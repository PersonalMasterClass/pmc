class AddHelpRequiredToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :help_required, :boolean, :default => false
  end
end
