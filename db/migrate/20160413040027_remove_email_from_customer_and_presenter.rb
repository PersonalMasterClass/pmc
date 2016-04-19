class RemoveEmailFromCustomerAndPresenter < ActiveRecord::Migration
  def change
  	remove_column :customers, :email, :string
  	remove_column :presenters, :email, :string
  end
end
