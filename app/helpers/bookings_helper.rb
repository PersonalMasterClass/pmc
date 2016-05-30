module BookingsHelper
	def duration(booking)
	 duration = booking.booking_date + booking.duration_minutes.minutes 
	 duration.strftime("%H:%M %p")
	end

	def booked_label(booking)
		presenter = booking.chosen_presenter
		if presenter.present?
			link_to "Presented by #{presenter.first_name} #{presenter.last_name}",  presenter_profile_path(presenter), class: "btn btn-xs btn-info"
		end
	end

	def rate_label(booking)
		if current_user.customer?
			if booking.creator == current_user.customer && booking.chosen_presenter.present?
				content_tag(:span, "Rate at #{number_to_currency(booking.rate)}", class: "btn btn-xs btn-success")	
			end
		end
	end

	def view_schools(booking)
		if booking.shared? && booking.customers.any?
			if booking.creator == current_user.customer || current_user.customer?
				content_tag(:span, "Number of schools joined: #{booking.customers.count}", class: "label label-primary")
			elsif current_user.presenter?
				render partial: 'bookings/partials/shared_booking_info', object: booking
			end
		end
	end

	def cancellation_message(booking)
		if booking.cancellation_message.present?
				content_tag(:p, "Cancellation message: <i>\"#{booking.cancellation_message}\"</i>".html_safe)
		end
	end
	def is_booked(booking,user)
		if user.presenter? 
			if booking.chosen_presenter == user.presenter 
				content_tag(:span, "booked", class: "label label-primary")
			elsif booking.bids.include? user.presenter.bids.find_by(booking: booking)
				content_tag(:span, "placed bid", class: "label label-primary")
			end
		elsif user.customer? #&& booking.creator == user.customer
				if booking.chosen_presenter.present?
					content_tag(:span, "confirmed", class: "label label-success")
				elsif booking.bids.any?
					content_tag(:span, "bids made", class: "label label-primary")
				else
					content_tag(:span, "pending", class: "label label-info")
				end
		elsif user.admin?
			if booking.chosen_presenter.present? 
				content_tag(:span, "booked by #{booking.chosen_presenter.first_name} #{booking.chosen_presenter.last_name}", class: "label label-primary")
			elsif booking.creator.present?
				content_tag(:span, "created by #{booking.creator.school_info.school_name}", class: "label label-primary")
			end
		end
	end

	def chosen_presenter(booking) 
		if booking.chosen_presenter == nil
			"none"
		else
			link_to "#{booking.chosen_presenter.first_name} #{booking.chosen_presenter.last_name}", presenter_profile_path(booking.chosen_presenter)
		end
	end

	def shared_message(booking)
		if booking.shared
			if booking.customers.count > 1
				"Shared with other school/s"
			else
				"Awaiting other schools"
			end
		else
			"Not open for sharing"
		end
	end

	def remaining_booking_slots(booking)
		@count = 0
		booking.booked_customers.each do |booked_customer|
			@count += booked_customer.number_students 
		end
		@remaining = booking.cap - @count
		return @remaining
end
