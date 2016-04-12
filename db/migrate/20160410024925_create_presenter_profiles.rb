class CreatePresenterProfiles < ActiveRecord::Migration
  def change
    create_table :presenter_profiles do |t|
      t.text :bio
      t.text :bio_edit
      t.integer :status
      t.string :picture
      t.string :picture_edit
      t.references :presenter, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
