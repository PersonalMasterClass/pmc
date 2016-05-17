module BookingsHelper
	def duration(booking)
	 duration = booking.booking_date + booking.duration_minutes.minutes 
	 duration.strftime("%H:%M %p")
	end

	def booked_label(booking)
		presenter = booking.chosen_presenter
		if presenter.present?
			link_to "Presented by #{presenter.first_name} #{presenter.last_name}",  presenter_profile_path(presenter), class: "btn btn-xs btn-primary"
		end
	end

	def is_booked(booking,user)
		if user.presenter? && booking.chosen_presenter == user.presenter 
			content_tag(:span, "booked", class: "label label-primary")
		elsif user.customer? && booking.creator == user.customer
			content_tag(:span, "owner", class: "label label-primary")
		elsif user.admin?
			if booking.chosen_presenter.present? 
				content_tag(:span, "booked by #{booking.chosen_presenter.first_name} #{booking.chosen_presenter.last_name}", class: "label label-primary")
			elsif booking.creator.present?
				content_tag(:span, "created by #{booking.creator.school_info.school_name}", class: "label label-primary")
			end
		end
	end
end
