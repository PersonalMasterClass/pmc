class Customer < ActiveRecord::Base
	belongs_to :school_info
	validates :first_name, :last_name, :phone_number,
						:vit_number, :department, :contact_title, presence: true
						
  # Retrieve user from presenter
  def get_user
  	users = User.unapproved_customers
  	users.each do |user|
  		if self == user.customer
  			return user
  		end
  	end
  	return false
  end

end
