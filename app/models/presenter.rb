class Presenter < ActiveRecord::Base
	belongs_to :school_info
  has_one :presenter_profile
  has_many :availabilitys

	validates :first_name, :last_name, :phone_number,
						:vit_number, presence: true
end
