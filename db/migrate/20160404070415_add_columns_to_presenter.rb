class AddColumnsToPresenter < ActiveRecord::Migration
  def change
    add_column :presenters, :first_name, :string
    add_column :presenters, :last_name, :string
    add_column :presenters, :phone_number, :string
    add_column :presenters, :vit_number, :string
    add_column :presenters, :abn_number, :string
    add_column :presenters, :school_id, :int
  end
end
