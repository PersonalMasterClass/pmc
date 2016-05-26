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

  def self.notify_applicable_users(creator, booking, type, reference)
  	if type == "presenter"
  		users = User.where(user_type: 1)
  		applicable_users = Presenter.joins(:subjects).where(subjects: {name: booking.subject.name})
  	elsif type == "customer"
  		applicable_users = Customer.joins(:subjects).where(subjects: {name: booking.subject.name})
  	end
  			
		message = "A new #{booking.subject.name} booking has been created that you may be interested in."
		reference = reference
  	applicable_users.each do |applicable_user|
  		unless applicable_user.user == creator
  			notification = Notification.create(message: message, reference: reference)
  			applicable_user.user.notifications << notification
  		end
  	end
	end
end
