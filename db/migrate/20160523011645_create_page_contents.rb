class CreatePageContents < ActiveRecord::Migration
  def change
    create_table :page_contents do |t|
      t.string :name
      t.text :content

      t.timestamps null: false
    end
  end
end
