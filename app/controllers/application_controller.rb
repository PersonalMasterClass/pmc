class ApplicationController < ActionController::Base
  # before_action :configure_permitted_parameters, if: :devise_controller? 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :is_suspended?
  before_action :profile_created?
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

  # Set notification as read on click 
  def notif_read
    notification = Notification.find(params[:id])
    notification.is_read = true
    notification.save
    redirect_to notification.reference
  end

  private

  # Check if current_user is suspended
    def is_suspended?
      if current_user
        if current_user.suspended?
          flash[:danger] = "You have been suspended!"
          sign_out(current_user)
        end
      end
    end
    
  # Check if current user has a profile
    def profile_created?
      if current_user
        if current_user.presenter
          if !current_user.presenter.presenter_profile
            flash[:info] = "Before you can do this, you must create your profile"
            redirect_to new_presenter_profile_path(current_user.presenter)
          end
        end
      end
    end

end
