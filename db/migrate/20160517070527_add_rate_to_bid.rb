class AddRateToBid < ActiveRecord::Migration
  def change
    add_column :bids, :rate, :integer
  end
end
