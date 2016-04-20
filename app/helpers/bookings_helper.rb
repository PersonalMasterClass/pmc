module BookingsHelper
	def display_nav
		if current_user.user_type == "presenter"
			render "presenters/partials/presenter_nav"
		elsif current_user.user_type == "customer"
			render "customers/partials/customer_nav"
		else
			render "users/partials/admin_nav"
		end
	end		
end
