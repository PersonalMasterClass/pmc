class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.integer :days
      t.integer :start_time
      t.integer :end_time
      t.integer :presenter_id

      t.timestamps null: false
    end
  end
end
