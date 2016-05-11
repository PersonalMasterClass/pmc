class ApplicationController < ActionController::Base
  # before_action :configure_permitted_parameters, if: :devise_controller? 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  # protected

#   def configure_permitted_parameters
#     # devise_parameter_sanitizer.permit(:sign_up) do |user_params|
#     #   user_params.permit({presenter: [
#     #                                    :user_id, :phone_number, :first_name, 
#     #                                    :last_name, :vit_number, :abn_number]},
#     #                                     :username, :email, :password, :password_confirmation)
#     # end
#     devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
#   end
	def notif_read
		notification = Notification.find(params[:id])
		notification.is_read = true
		notification.save
		redirect_to notification.reference
	end

end
