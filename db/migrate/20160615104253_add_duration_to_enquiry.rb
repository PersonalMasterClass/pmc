class AddDurationToEnquiry < ActiveRecord::Migration
  def change
		add_column :enquiries, :duration, :integer
  end
end
