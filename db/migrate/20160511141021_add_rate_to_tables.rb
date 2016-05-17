class AddRateToTables < ActiveRecord::Migration
  def change
 		add_column :bookings, :rate, :integer
  	add_column :presenters, :rate, :integer
  end
end
