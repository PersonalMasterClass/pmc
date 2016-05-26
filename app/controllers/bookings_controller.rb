class BookingsController < ApplicationController
  before_filter :admin_or_customer_logged_in, :except => [:index, :show, :open, :set_bid]

  def index  
    # Refactored to presenter/customer/admin controllers
    # @upcoming = Booking.upcoming(current_user) 
    # @completed = Booking.completed(current_user)
    # if current_user.user_type == "customer"
      # @upcoming += Booking.where(creator: current_user.customer)
    # end
  end

  def show
    @booking = Booking.find(params["id"])
    @creator = @booking.creator
  end

  def new
    # Booking form is populated if visited via search form.
    if session[:search_params].present?
      @subject_select = session[:search_params]["subject_name"]
      @subject_id = session[:search_params]["subject_id"]
      @date_part = session[:search_params]["date_part"]
      @time_part = session[:search_params]["time_part"]
      @presenter_id = params[:presenter_id]
      @booking = Booking.new(subject_id: @subject_id) 
    else
      @booking = Booking.new
    end
  end

  def create
    @booking = Booking.new(booking_params)
    if session[:search_params].present?
      @booking.chosen_presenter = Presenter.find(params[:presenter_id])
      @booking.creator = current_user.customer
    end

    @subject = Subject.find(params[:subject_id])
    # TODO date and time validation
    date = (params['date_part'] + " " + params['time_part']).to_datetime
    @booking.booking_date = date
    # TODO: Refactor for admin booking creation
    @booking.shared = params["shared"]
    @booking.subject = @subject
    # Add this customer as owner. 
    @booking.creator = current_user.customer
    @booking.save

    # Send messages to customers if booking is shared
    if @booking.shared?
      Notification.notify_applicable_users(current_user, @booking, "customer", booking_path(@booking))
    end
    Notification.notify_applicable_users(current_user, @booking, "presenter", booking_path(@booking))
    Notification.notify_admin("A new booking has been created", booking_path(@booking))

    # Add booking to booked customers
    current_user.customer.created_bookings << @booking

    #clear search session 
    session[:search_params] = nil
    redirect_to @booking

  end

  def edit
  end

  def update
  end

  def destroy
  end

  def open
    @bookings = Booking.where(chosen_presenter_id: nil)
  end

  def set_bid
    @booking = Booking.find(params[:id])
    @presenter = current_user.presenter
    # This will create a bi directional association, @booking will contain @presenter as well.
    if @booking.presenters.include? @presenter
      flash[:info] = "You have already expressed interest in this booking"
      redirect_to bookings_open_path
    else
      @presenter.bookings << @booking
      @bid = Bid.where(booking: @booking, presenter: @presenter).first
      @bid.bid_date = DateTime.now
      @bid.rate = params[:rate]
      @presenter.save
      @bid.save
    end

    Notification.send_message(@booking.creator.user, "#{@presenter.first_name} has expressed an interest in this booking.", booking_path(@booking))
    flash[:success] = "You have successfully placed a bid on this booking."
    redirect_to presenters_path
  end

  def choose_presenter
    @presenter = Presenter.find(params[:presenter_id])
    @booking = Booking.find(params[:booking_id])
    
    @booking.chosen_presenter = @presenter
    @booking.rate = @presenter.bids.find_by(booking: booking).rate
    @booking.save
    @booking.remove_all_bids

    Notification.send_message(@presenter.user, "You've been locked in for a booking!", booking_path(@booking))
    flash[:success] = "#{@presenter.get_private_full_name(current_user)} has been assigned to this booking."
    
    redirect_to root_path
  end

  def get_help 
    @booking = Booking.find(params[:id])
    owner = @booking.creator
    Notification.notify_admin("#{owner.first_name} #{owner.last_name} has asked for help choosing a presenter for their booking", booking_path(@booking))
    flash[:info] = "An admin has been notified that you would like help choosing. They will be in contact with you shortly"
    @booking.help_required = true
    @booking.save
    redirect_to booking_path(@booking)
  end

  def join
    @booking = Booking.find(params[:id])
    @booking.customers << current_user.customer
    Notification.notify_admin("#{current_user.customer.first_name} of #{current_user.customer.school_info.school_name} has joined a booking.", booking_path(@booking))
    Notification.send_message(@booking.creator.user, "A school has joined your booking.", booking_path(@booking))
    flash[:success] = "Success! You've joined the booking!"
    redirect_to booking_path(@booking)
  end

  def cancel_booking
  end

  def cancel_bid
  end

  private
    def booking_params
      params.require(:booking).permit(:duration_minutes, :presenter_paid, :period, :shared)
    end

    def admin_or_customer_logged_in
      if current_user.nil? || (current_user.user_type == "presenter") 
        flash[:danger] = "Only admin and customer are allowed to create a booking."
        redirect_to root_url        
      end
    end
end



