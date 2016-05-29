class AddIndexToPageContentName < ActiveRecord::Migration
  def change
    add_index :page_contents, :name
  end
end
