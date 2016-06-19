class AddRateToTables < ActiveRecord::Migration
  def change
 		add_column :bookings, :rate, :integer, :default => 0
  	add_column :presenters, :rate, :integer, :default => 0
  end
end
