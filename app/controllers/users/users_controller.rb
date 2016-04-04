class Users::UsersController < ApplicationController::Base

  def new

  end


  def create

      unless current_user.user_type == 2 && current_user.status == 1
          redirect_to :back, :alert => "Admin Access denied."
      end

  end

end
