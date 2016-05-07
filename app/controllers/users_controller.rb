  class UsersController < ApplicationController
  before_filter :admin_only, only: [:management_console, :registrations, :approve_user, :suspend]
  
  # given a user, will redirect to the relevant profile
  # either presenter profile, or customer profile
  def show
    user = User.find(params[:id])
    if user.presenter.nil? && user.customer.nil?
      redirect_to root_url
    elsif user.presenter
      redirect_to presenter_profile_path(user.presenter)
    else #user.customer
      redirect_to customer_path(user.customer)
    end
  end
  

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
    previous_status = user.status
    user.status = "approved"
    user.save
    Notification.send_message(user, "Your account has been approved!", "")
    if user.presenter.present?
      flash[:success] = "#{user.presenter.first_name} #{user.presenter.last_name}'s
                        account has been approved."
    elsif user.customer.present?
      flash[:success] = "#{user.customer.first_name} #{user.customer.last_name}'s 
                        account has been approved."
    end
    if previous_status == "pending"
      redirect_to admin_pending_registrations_path
    else
      redirect_to user_path(user)
    end
  end

  def suspend_user
    user = User.find(params[:id])
    user.status = "suspended"
    user.save
    Notification.send_message(user, "Your account has been suspended", "")
    if user.presenter.present?
      flash[:success] = "#{user.presenter.first_name} #{user.presenter.last_name}'s
                        account has been suspended."
    elsif user.customer.present?
      flash[:success] = "#{user.customer.first_name} #{user.customer.last_name}'s 
                        account has been suspended."
    end
    redirect_to user_path(user)
  end

  private
  def admin_only
    if current_user.nil? || current_user.user_type != "admin" && current_user.status != "approved"
      flash[:danger] = "Unauthorised access."
      redirect_to root_url
    end
  end

end
