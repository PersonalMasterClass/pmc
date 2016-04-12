class Presenter < ActiveRecord::Base

  has_one :presenter_profile

	validates :first_name, :last_name, :email, :phone_number,
						:vit_number, presence: true
	validates :email, uniqueness: true

end
