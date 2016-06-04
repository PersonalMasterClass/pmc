class AddUrlToPageContent < ActiveRecord::Migration
  def change
    add_column :page_contents, :url, :string
  end
end
