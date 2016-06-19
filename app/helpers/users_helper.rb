module UsersHelper

	# Display registration count
	def pending_count(presenter, customer)
		total_pending = presenter.count + customer.count
		if total_pending > 0
			"There are #{total_pending} pending registrations."
		else
			"There are no pending registrations."
		end
	end

	# Depreciated nav display logic
	def dashboard_active?
		unless params[:controller] == 'users' && params[:action] == 'index' 
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def p_rego_active?
		unless params[:controller] == 'users' && params[:action] == 'registrations'
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def subject_active?
		unless params[:controller] == 'subjects' && params[:action] == 'index'
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def p_profile_active?
		unless params[:controller] == 'presenter_profiles' && params[:action] == 'pending'
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def presenter_search_active?
		unless params[:controller] == 'search' && params[:action] == 'index'
			return ''
		end
		return 'active'
	end
	
	# Depreciated nav display logic
	def suspended_users_active? 
		unless params[:controller] == 'users' && params[:action] == 'suspended_users'
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def search_active?
		unless current_page?(profiles_search_path)
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def schools_active?
		unless current_page?(admin_customers_path)
			return ''
		end
		return 'active'
	end

	# Depreciated nav display logic
	def presenters_active?
		unless current_page?(admin_presenters_path)
			return ''
		end
		return 'active'
	end


	# Check school info params
	def if_params_school_info?(field, params)
		if params[:school_info].nil?
			''
		else
			params[:school_info][field]
		end
	end

	# Check customer params
	def if_params_customer?(field, params)
		if params[:customer].nil?
			''
		else
			params[:customer][field]
		end
	end

	# Check presenter params
	def if_params_presenter?(field, params)
		if params[:presenter].nil?
			''
		else
			params[:presenter][field]
		end
	end
end
