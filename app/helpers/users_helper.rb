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
end
