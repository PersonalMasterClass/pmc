module UsersHelper
	def pending_count(presenter, customer)
		total_pending = presenter.count + customer.count
		if total_pending > 0
			"There are #{total_pending} pending registrations."
		else
			"There are no pending registrations."
		end
	end

	def dashboard_active?
		unless params[:controller] == 'users' && params[:action] == 'index' 
			return ''
		end
		return 'active'
	end
	def p_rego_active?
		unless params[:controller] == 'users' && params[:action] == 'registrations'
			return ''
		end
		return 'active'
	end
	def subject_active?
		unless params[:controller] == 'subjects' && params[:action] == 'index'
			return ''
		end
		return 'active'
	end
	def p_profile_active?
		unless params[:controller] == 'presenter_profiles' && params[:action] == 'pending'
			return ''
		end
		return 'active'
	end
	def presenter_search_active?
		unless params[:controller] == 'search' && params[:action] == 'index'
	end
	
	def suspended_users_active? 
		unless params[:controller] == 'users' && params[:action] == 'suspended_users'
			return ''
		end
		return 'active'
	end
	def search_active?
		unless current_page?(profiles_search_path)
			return ''
		end
		return 'active'
	end
	def schools_active?
		unless current_page?(admin_customers_path)
			return ''
		end
		return 'active'
	end
	def presenters_active?
		unless current_page?(admin_presenters_path)
			return ''
		end
		return 'active'
	end


	def if_params_school_info?(field, params)
		if params[:school_info].nil?
			''
		else
			params[:school_info][field]
		end
	end

	def if_params_customer?(field, params)
		if params[:customer].nil?
			''
		else
			params[:customer][field]
		end
	end
	def if_params_presenter?(field, params)
		if params[:presenter].nil?
			''
		else
			params[:presenter][field]
		end
	end
end
