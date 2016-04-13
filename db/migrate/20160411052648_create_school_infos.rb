class CreateSchoolInfos < ActiveRecord::Migration
  def change
    create_table :school_infos do |t|
      t.string :sector
      t.string :school_name
      t.string :school_type
      t.string :principal
      t.string :address
      t.string :town
      t.string :state
      t.string :postcode
      t.string :postal_address
      t.string :postal_town
      t.string :postal_state
      t.string :postal_postcode
      t.string :phone_number
      t.string :fax_number
      t.string :region_name
      t.string :lga_name

      t.timestamps null: false
    end
  end
end
