class Customer < ActiveRecord::Base
	belongs_to :school_info
	validates :first_name, :last_name, :phone_number,
						:vit_number, :department, :contact_title, presence: true


end
