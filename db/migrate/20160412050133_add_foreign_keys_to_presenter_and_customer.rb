class AddForeignKeysToPresenterAndCustomer < ActiveRecord::Migration
  def change
  	add_column :customers, :school_info_id, :integer
  	add_column :presenters, :school_info_id, :integer
  end
end
