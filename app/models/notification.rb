class Notification < ActiveRecord::Base
	# User notified and emailed upon account creation
	def self.send_message(user, message, reference)
		notification = Notification.create(message: message, reference: reference)
		user.notifications << notification
	end

  # Admin(s) are notified when a new account has been created
	def self.new_registration
		reference = "/admin/registrations"
		message = "A new registration has been submitted for approval."
		notification = Notification.create(message: message, reference: reference)
		# Add notification to all admins
		admin_users = User.where(user_type: 2)
		admin_users.each do |admin|
			admin.notifications << notification
	    UserMailer.registration_mail(admin).deliver_now
		end
	end

  def self.notify_applicable_presenters(subject)
  	users = User.where(user_type: "presenter")
		message = "A new #{subject.name} booking has been created that you may be interested in."
		reference = nil
  	users.each do |user|
  		notification = Notification.create(message: message, reference: reference)
  		user.notifications << notification
  	end
	end
end
