module EnquiriesHelper
	def from(enquiry)
		if current_user.customer?
			if enquiry.from == "presenter"
				"Enquiry from: #{enquiry.presenter.get_private_full_name(current_user)}"
			elsif enquiry.from == "customer"
				"Your enquiry"
			end
		elsif current_user.presenter?
			if enquiry.from == "presenter"
				"Your enquiry"
			elsif enquiry.from == "customer"
				"Enquiry from: #{enquiry.customer.school_info.school_name}"
			end
		else current_user.admin?
			"Enquiry between: #{enquiry.presenter.get_private_full_name(current_user)}
								#{enquiry.customer.school_info.school_name}"
		end

	end
	def enquiry_user(user)
		if params[:id].present?
			status = Enquiry.find(params[:id]).status
			if status == "pending" || status == "counteroffer" 
			"Counter offer"
			end
		elsif user.customer? 
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
		elsif params[:action] == "create" && params[:controller] == "enquiries"
			return params[:enquiry][:recipient_id]
		end
	end		

	def name_or_school(user)
		if current_user.customer?
			user.get_private_full_name(current_user)
		elsif current_user.presenter?
			user.school_info.school_name
		end
	end
	def enquiry_panel_color(enquiry) 
		if enquiry.accepted? || enquiry.booked?
			"success"
		elsif enquiry.declined?
			"danger"
		else
			"primary"
		end
	end

	def enquiry_status(enquiry)
		if enquiry.accepted?
			content_tag(:span, "ACCEPTED", class: "btn btn-xs btn-success")	
		elsif enquiry.declined?
			content_tag(:span, "DECLINED", class: "btn btn-xs btn-danger")	
		elsif enquiry.counteroffer?
			content_tag(:span, "COUNTER OFFER", class: "btn btn-xs btn-primary")	
		elsif enquiry.booked?
			content_tag(:span, "BOOKED", class: "btn btn-xs btn-success")	
		else
			content_tag(:span, "PENDING", class: "btn btn-xs btn-primary")	
		end
	end

	def current_enquiry(index)
		if index == 0
			return "list-group-item-success"
		else
			return "disabled"
		end
	end

	def enquiry_actions(enquiry)
		selection = nil
		if enquiry.pending?
			if current_user.presenter?
				selection = :all_btns
			elsif current_user.customer?
				selection = :decline_btn
			end
		elsif enquiry.accepted?
			if current_user.presenter?
				selection = :decline_btn
			elsif current_user.customer?
				selection = :create_decline_btn
			end
		elsif enquiry.counteroffer?
			if current_user.presenter?
				selection = :decline_btn
			elsif current_user.customer?
				selection = :all_btns
			end
		elsif enquiry.booked?
			if current_user.presenter?
				selection = :back
			elsif current_user.customer?
				selection = :back
			end
		end

		if selection == :all_btns
			concat link_to "Accept", enquiry_accept_path(enquiry), method: :patch, class: "btn btn-success"
			concat render "enquiries/partials/form"
			link_to "Decline", enquiry_decline_path(enquiry), method: :patch, class: "btn btn-danger" 
		elsif selection == :decline_btn
			link_to "Decline", enquiry_decline_path(enquiry), method: :patch, class: "btn btn-danger" 
		elsif selection == :back
			link_to "Back", :back, class: "btn btn-default" 
		elsif selection == :create_decline_btn
			concat link_to "Create Booking", enquiry_booked_path(enquiry), method: :get, class: 'btn btn-success' 
			link_to "Decline", enquiry_decline_path(enquiry), method: :patch, class: "btn btn-danger" 
		end	
	end
end





















