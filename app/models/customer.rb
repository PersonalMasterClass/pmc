class Customer < ActiveRecord::Base
	validates :first_name, :last_name, :phone_number,
						:vit_number, :department, :contact_title, presence: true
end
