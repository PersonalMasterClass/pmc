module CustomersHelper
	def fullname(customer)
		"#{customer.first_name} #{customer.last_name}"
	end

	def display_admin_or_customer_nav
		if current_user.user_type == "customer"
			render "customers/partials/customer_nav"
		else
			render "users/partials/admin_nav"
		end
	end		

	def c_dashboard_active?
		unless params[:controller] == 'customers' && params[:action] == 'index' 
			return ''
		end
		return 'active'
	end

	def new_booking_active?
		unless params[:controller] == 'bookings' && params[:action] == 'new'
			return ''
		end
		return 'active'
	end

end
