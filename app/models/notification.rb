class Notification < ActiveRecord::Base
	# User notified and emailed upon account creation
	def self.approve_registration(user)
		reference = nil
		message = "You're account has been approved! Welcome."
		notification = Notification.create(message: message, reference: reference)
		user.notifications << notification
	end

  # Admin(s) are notified when a new account has been created
	def self.new_registration
		reference = "/admin/registrations"
		message = "A new registration has been submitted for approval."
		notification = Notification.create(message: message, reference: reference)
		# Add notification to all admins
		admin_users = User.where(user_type: "admin")
		admin_users.each do |admin|
			admin.notifications << notification
	    UserMailer.registration_mail(admin).deliver_now
		end

	end
end
