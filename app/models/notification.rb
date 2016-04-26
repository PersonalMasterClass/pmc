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
		admin_users = User.where(user_type: "admin")
		admin_users.each do |admin|
			admin.notifications << notification
	    UserMailer.registration_mail(admin).deliver_now
		end
	end

  def self.notify_applicable_users(subject, type)
  	if type == "presenter"
  		users = User.where(user_type: "presenter")
  	elsif type == "customer"
  		users = User.where(user_type: "customer")
  	end
  			
		message = "A new #{subject.name} booking has been created that you may be interested in."
		reference = nil
  	users.each do |user|
  		notification = Notification.create(message: message, reference: reference)
  		user.notifications << notification
  	end
	end
end
