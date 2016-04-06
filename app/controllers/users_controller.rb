class UsersController < ApplicationController
before_filter :admin_only, only: [:management_console]

  def management_console

  end

  def registrations
    @unapproved_users = User.where(status: 0)
  end


  private
  def admin_only
    if current_user.nil? || current_user.user_type != "admin" && current_user.status != "approved"
      flash[:danger] = "Unauthorised access."
      redirect_to '/'
    end
  end

end
