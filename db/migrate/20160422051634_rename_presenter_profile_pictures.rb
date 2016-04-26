class RenamePresenterProfilePictures < ActiveRecord::Migration
  def change
    change_table :presenter_profiles do |t|
      t.rename :picture, :picture_uid
      t.rename :picture_edit, :picture_edit_uid
    end
  end
end
