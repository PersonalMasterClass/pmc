class Notification < ActiveRecord::Base
	# User notified and emailed upon account creation
	def self.send_message(user, message, reference)
		notification = Notification.create(message: message, reference: reference)
		user.notifications << notification
	end

  # Admin(s) are notified when a new account has been created
	def self.notify_admin(message, reference)
		notification = Notification.create(message: message, reference: reference)
		# Add notification to all admins
		admin_users = User.where(user_type: 2)
		admin_users.each do |admin|
			admin.notifications << notification
		end
	end

  def self.notify_applicable_users(creator, booking, type, reference, message)
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
  		end
  	end
	end

	def self.cancelled_booking(booking, reference)
		message = "One of your bookings have been cancelled"
		notification = Notification.create(message: message, reference: reference)
		booking.presenters.each do |presenter|
			presenter.user.notifications << notification
		end
		booking.customers.each do |customer|
			customer.user.notifications << notification
		end

		if booking.chosen_presenter.present?
			booking.chosen_presenter.user.notifications << notification
		end
		notify_admin(message, reference)
	end
end
