module BookingsHelper

	# Display booking duration
	def duration(booking)
	 duration = booking.booking_date + booking.duration_minutes.minutes 
	 duration.strftime("%H:%M %p")
	end

	# Display booked label
	def booked_label(booking)
		presenter = booking.chosen_presenter
		if presenter.present?
			link_to "Presented by #{presenter.get_private_full_name(current_user)}",  presenter_profile_path(presenter), class: "btn btn-xs btn-info"
		end
	end

	# Display rate label
	def rate_label(booking)
		if current_user.customer?
			if booking.creator == current_user.customer && booking.chosen_presenter.present?
				content_tag(:span, "Rate at #{number_to_currency(booking.rate)}", class: "btn btn-xs btn-info")	
			end
		end
	end

	# Display bid label
	def bid_label(booking)
		if current_user.presenter?
			if booking.presenters.include? current_user.presenter
				content_tag(:span, "Your bid is: #{number_to_currency(current_user.presenter.bids.find_by(booking: booking).rate)}", class: "btn btn-xs btn-info")	
			end
		end
	end

	# Display booking capacity label
	def capacity_label(booking)
		if booking.remaining_slots == 0
			content_tag(:span, "Booking full", class: "btn btn-xs btn-danger")	
		end
	end

	# Selective display for a shared booking
	def view_schools(booking)
		if booking.shared? && booking.customers.any?
			if booking.creator == current_user.customer || current_user.customer?
				content_tag(:span, "Number of schools joined: #{booking.customers.count}", class: "label label-primary")
			elsif current_user.presenter?
				render partial: 'bookings/partials/shared_booking_info', object: booking
			end
		end
	end

	# Display cancellation message
	def cancellation_message(booking)
		if booking.cancellation_message.present?
				content_tag(:p, "Cancellation message: <i>\"#{booking.cancellation_message}\"</i>".html_safe)
		end
	end

	# Booking tag to display state of a booking
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

	# Display presenter details of closed booking or a presenter is chosen for an open booking
	def chosen_presenter(booking) 
		if booking.chosen_presenter == nil
			"none"
		else
			link_to "#{booking.chosen_presenter.first_name} #{booking.chosen_presenter.last_name}", presenter_profile_path(booking.chosen_presenter)
		end
	end

	# Shared booking message
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

	# Display remaining capacity of a booking
	def display_booking_slots(booking)
		if @remaining != 0
			return "#{booking.cap - booking.remaining_slots}/30 students booked."
		end
	end
end
