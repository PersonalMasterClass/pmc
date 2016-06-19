class Notification < ActiveRecord::Base

	# Check user settings and decide what type of email to send
	def self.send_email(user, message, reference, setting)
		if BookingMailer.instance_methods.grep(setting).present? && user.setting.booking?
			BookingMailer.public_send(setting, user, message, reference).deliver_now
		elsif QueryMailer.instance_methods.grep(setting).present? && user.setting.enquiry?
			QueryMailer.public_send(setting, user, message, reference).deliver_now
		end
	end

	# User notified and emailed upon account creation
	def self.send_message(user, message, reference, setting)
		notification = Notification.create(message: message, reference: reference)
		user.notifications << notification
		send_email(user, message, reference, setting)
	end

  # Admin(s) are notified when a new account has been created
	def self.notify_admin(message, reference, setting)
		notification = Notification.create(message: message, reference: reference)
		# Add notification to all admins
		admin_users = User.where(user_type: 2)
		admin_users.each do |admin|
			admin.notifications << notification
			send_email(admin, message, reference, setting)
		end
	end

  def self.notify_applicable_users(creator, booking, type, reference, message, setting)
  	if type == "presenter"
  		users = User.where(user_type: 1)
  		applicable_users = Presenter.joins(:subjects).where(subjects: {name: booking.subject.name})
  	elsif type == "customer"
  		applicable_users = Customer.joins(:subjects).where(subjects: {name: booking.subject.name})
  	end
  			
		reference = reference
  	applicable_users.each do |applicable_user|
  		unless applicable_user.user == creator
  			notification = Notification.create(message: message, reference: reference)
  			applicable_user.user.notifications << notification
  			send_email(applicable_user.user, message, reference, setting)
  		end
  	end
	end


	def self.cancelled_booking(booking, reference)
		message = "One of your bookings have been cancelled"
		notification = Notification.create(message: message, reference: reference)

    booking.creator.user.notifications << notification
    BookingMailer.cancel_booking(booking.creator.user, message, reference).deliver_now

		booking.presenters.each do |presenter|
			presenter.user.notifications << notification
			BookingMailer.cancel_booking(presenter.user, message, reference).deliver_now
		end
		booking.customers.each do |customer|
			customer.user.notifications << notification
			BookingMailer.cancel_booking(customer.user, message, reference).deliver_now
		end

		if booking.chosen_presenter.present?
			booking.chosen_presenter.user.notifications << notification
			BookingMailer.cancel_booking(booking.chosen_presenter.user, message, reference).deliver_now
		end

		admin_users = User.where(user_type: 2)
		admin_users.each do |admin|
			admin.notifications << notification
			BookingMailer.cancel_booking(admin, message, reference).deliver_now
		end
	end
end
