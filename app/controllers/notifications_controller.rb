class NotificationsController < ApplicationController
  skip_before_filter :profile_created?
	def index
		if current_user
			@notifications = current_user.notifications.order(created_at: :desc)
		end
	end
end
