  class UsersController < ApplicationController
  before_filter :admin_only, only: [:management_console, :registrations, :approve_user]
  

  

  def index
    @pending_user_count = User.where(status: "pending").count
  end

  def success
  end

  def registrations
    @presenters = User.unapproved_presenters
    @customers = User.unapproved_customers
  end

  def approve_user
    user = User.find(params["id"])
    user.status = "approved"
    user.save
    Notification.approve_registration(user)
    if user.presenter.present?
      flash[:success] = "#{user.presenter.first_name} #{user.presenter.last_name}'s
                        account has been approved."
    elsif user.customer.present?
      flash[:success] = "#{user.customer.first_name} #{user.customer.last_name}'s 
                        account has been approved."
    end
    redirect_to admin_pending_registrations_path
  end
  private
  def admin_only
    if current_user.nil? || current_user.user_type != "admin" && current_user.status != "approved"
      flash[:danger] = "Unauthorised access."
      redirect_to '/'
    end
  end

end
