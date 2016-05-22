  class UsersController < ApplicationController
  before_filter :admin_only, only: [:registrations, 
                                    :approve_user, 
                                    :suspend,
                                    :suspended_users,
                                    :customers,
                                    :presenters,
                                    :index]
  
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
    @pending_user_count = User.unapproved_customers.count
    @pending_profile_count = PresenterProfile.drafts_and_unapproved.count
    @help_count = Booking.help_required.count
    @total = @pending_user_count + @pending_profile_count + @help_count
     
    @search_params = params

    #pending presenter accounts
    @customers = User.unapproved_customers.first(5)

    #pending profile changes
    #@profiles = PresenterProfile.find(:first, :conditions => {status: "pending_admin"}, limit: 5)
    @profiles = PresenterProfile.drafts_and_unapproved.first(5)

    @upcoming_bookings = Booking.upcoming(current_user).first(5)
    @help_bookings = Booking.upcoming(current_user).where(help_required: true).first(5)

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
      user.presenter.remove_upcoming_bookings
      user.presenter.remove_all_bids
      flash[:success] = "#{user.presenter.first_name} #{user.presenter.last_name}'s
                        account has been suspended."
    elsif user.customer.present?
      flash[:success] = "#{user.customer.first_name} #{user.customer.last_name}'s 
                        account has been suspended."
    end
    redirect_to user_path(user)
  end

  def suspended_users
    @customers = User.suspended_customers
    @presenters = User.suspended_presenters
  end

  def customers
    @customers = Customer.all
  end

  def presenters
    @presenters = Presenter.all
  end

  private

  def admin_only
    if current_user.nil? || current_user.user_type != "admin" && current_user.status != "approved"
      flash[:danger] = "Unauthorised access."
      redirect_to root_url
    end
  end

end
