module CustomersHelper
	# Display the full name of a customer
	def fullname(customer)
		"#{customer.first_name} #{customer.last_name}"
	end

	# Select render of nav
	def display_admin_or_customer_nav
		if current_user.user_type == "customer"
			render "customers/partials/customer_nav"
		else
			render "users/partials/admin_nav"
		end
	end		

	# Depreciated method for display active navs
	def c_dashboard_active?
		unless params[:controller] == 'customers' && params[:action] == 'index' 
			return ''
		end
		return 'active'
	end

	# Depreciated method for display active navs
	def new_booking_active?
		unless params[:controller] == 'bookings' && params[:action] == 'new'
			return ''
		end
		return 'active'
	end

end
