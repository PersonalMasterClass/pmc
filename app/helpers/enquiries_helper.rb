module EnquiriesHelper
	def from(enquiry)
		if current_user.customer?
			content_tag(:h3, "Enquiry from: #{enquiry.presenter.get_private_full_name(current_user)}")
		elsif current_user.presenter?
			content_tag(:h3, "Enquiry from: #{enquiry.customer.school_info.school_name}")
		elsif current_user.admin?
			content_tag(:h3, "Enquiry between: #{enquiry.presenter.get_private_full_name(current_user)}
											#{enquiry.customer.school_info.school_name}")
		end
	end
	def enquiry_user(user)
		if user.customer?
			"Enquiry now"
		elsif user.presenter?
			"Counter offer"
		end
	end

	def form_title(user)
		if user.customer?
			"Make enquiry"
		elsif user.presenter?
			"Make counter offer"
		end
	end
	def enquiry_submit(user)
		if user.customer?
			"Send enquiry"
		elsif user.presenter?
			"Send counter offer"
		end
	end

	def form_variable(enquiry, presenter)
		if params[:action] == "show" && params[:controller] == "presenter_profiles"
			return presenter.id
		elsif params[:action] == "show" && params[:controller] == "enquiries"
			if current_user.customer?
				return enquiry.presenter.id
			elsif presenter.present?
				return enquiry.customer.id
			end
		end
	end		

	def name_or_school(user)
		if current_user.customer?
			user.get_private_full_name(current_user)
		elsif current_user.presenter?
			user.school_info.school_name
		end
	end

	def current_enquiry(index)
		if index == 0
			return "primary"
		else
			return "default"
		end
	end
end





















