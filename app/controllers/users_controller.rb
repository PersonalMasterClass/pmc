class UsersController < ApplicationController
before_filter :admin_only, only: [:management_console]

  def management_console

  end


  private
  def admin_only
    if current_user.nil? || current_user.user_type != 2 && current_user.status != 1
      flash[:danger] = "Unauthorised access."
      redirect_to '/'
    end
  end

end
