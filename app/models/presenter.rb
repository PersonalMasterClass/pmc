class Presenter < ActiveRecord::Base
	validates :first_name, :last_name, :email, :phone_number,
						:vit_number, presence: true
	validates :email, uniqueness: true
end
