class CreateBidsJoinTable < ActiveRecord::Migration
  def change
		create_table :bids do |t|
      t.references :booking
      t.references :presenter
 			t.datetime :bid_date
		end
	end
end
