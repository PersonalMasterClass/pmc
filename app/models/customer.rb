class Customer < ActiveRecord::Base
	validates :first_name, :last_name, :email, :phone_number,
						:vit_number, :department, :contact_title, presence: true
	validates :email, uniqueness: true
end
