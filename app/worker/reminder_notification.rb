class ReminderNotification
  @queue = :notification_queue
  # Remind presenter to update profile 1 day after account creation if any details are nil
  def self.perform(user_id)
    user = User.find(user_id)
		profile = user.presenter.presenter_profile

		flag = false
		if profile.nil?
			flag = true
		elsif profile.bio.present? || profile.picture.present? 
			flag = true
		end  
		if flag == true
			reference = "/presenters/#{user.presenter.id}/presenter_profile/edit"
			message = "It looks like you haven't updated your profile yet,
								 please update your profile for a greater chance to be matched."
			notification = Notification.create(message: message, reference: reference)
			user.notifications << notification
		end
	end
end