class BiannualUpdate
  @queue = :biannual_update_queue
  # Remind presenter to update profile 1 day after account creation if any details are nil
  def self.perform(user_id)
    user = User.find(user_id)
    # Presenter may have chosen to no longer use the service
    if user.present?
			reference = "/presenters/#{user.presenter.id}/presenter_profile/edit"
			message = "The new term is just ahead of us, make sure to make any 
									necessary updates to your profile."
			notification = Notification.create(message: message, reference: reference)
			user.notifications << notification
		end
	end
end