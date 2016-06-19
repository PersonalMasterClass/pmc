module PresentersHelper
	# Selective render of nav
	def display_admin_or_presenter_nav
		if current_user.user_type == "presenter"
			render "presenters/partials/presenter_nav"
		else
			render "users/partials/admin_nav"
		end
	end		

	# Depreciated nav display logic
	def p_dashboard_active?
		unless params[:controller] == 'presenters' && params[:action] == 'index' 
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def view_profile_active?
		unless params[:controller] == 'presenter_profiles' && params[:action] == 'show'
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def edit_profile_active?
		unless params[:controller] == 'presenter_profiles' && (params[:action] == 'edit' || params[:action] == "new")
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def open_bookings_active?
		unless params[:controller] == 'bookings' && params[:action] == 'open'
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def my_bookings_active?
		unless params[:controller] == 'bookings' && params[:action] == 'index'
			return ''
		end
		return 'active'
	end
end

