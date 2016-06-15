class BookingMailer < ApplicationMailer
	# Send email to interested user regarding a newly created booking
  def interested_booking(user, message, reference)
  	@reference = "#{root_url}#{reference}"
  	if user.customer?
  		@name = user.customer.school_info.school_name
  	elsif user.presenter?
  		@name = user.presenter.first_name
  	end
  	subject = "You may be interested in a new booking that has been created."
  	mail(to: user.email, subject: message)
  end

  # Send email to admin regarding a newly created booking
  def booking(admin, message, reference)
  	@reference = "#{root_url}#{reference}"
		mail(to: admin.email, subject: message)
  end

  # Send email to the creator of a booking about a bid that has been placed 
  def bid(user, message, reference)
  	@user = user
  	@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
  end

  # Chosen presenter is emailed about being chosen for a booking
	def choose_presenter(user, message, reference)
		@user = user
		@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end

  # Admin is emailed about help in creating a booking
	def get_help(user, message, reference)
		@user = user
		@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end

	# Booking creator is emailed regarding a school joining their booking
	def join(user, message, reference)
		if user.customer?
			@name = user.customer.school_info.school_name
		else
			@name = "Admin"
		end
		@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end

	# Booking creator is emailed regarding a presenter withdawing their bid
	def cancel_bid(user, message, reference)
		@user = user
		@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end

	# Booking creator is emailed regarding a school leaving their booking
	def leave_booking(user, message, reference)
		@user = user
		@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end

	# Booking creator is emailed regarding a school leaving their booking
	def cancel_booking(user, message, reference)
  	if user.customer?
  		@name = user.customer.school_info.school_name
  	elsif user.presenter?
  		@name = user.presenter.first_name
  	else
  		@name = "Admin"
  	end
  	@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end
end
