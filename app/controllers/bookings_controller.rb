class BookingsController < ApplicationController
  before_filter :admin_or_customer_logged_in, :except => [:index, :show, :open, :bid]

  def index  
    @upcoming = Booking.upcoming(current_user) 
    @completed = Booking.completed(current_user)
    if current_user.user_type == "customer"
      @upcoming += Booking.where(creator: current_user.customer)
    end
  end

  def show
    @booking = Booking.find(params["id"])
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
    
    @booking.subject = @subject
    # Add this customer as owner. 
    @booking.creator = current_user.customer


    @booking.save

    # Send messages to customers if applicable && @booking is open
    if @booking.chosen_presenter.nil?
      Notification.notify_applicable_users(current_user, @booking, "customer", "/bookings/#{@booking.id}")
    end
    Notification.notify_applicable_users(current_user, @booking, "presenter", "/bookings/#{@booking.id}")
    Notification.notify_admin("A new booking has been created", "/bookings/#{@booking.id}")

    # Add booking to booked customers
    current_user.customer.bookings << @booking

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

  def bid
    @booking = Booking.find(params[:id])
    @presenter = current_user.presenter
    # This will create a bi directional association, @booking will contain @presenter as well.
    if @booking.presenters.include? @presenter
      flash[:info] = "You have already expressed interest in this booking"
      redirect_to bookings_open_path
    else
      @presenter.bookings << @booking
      @presenter.bids.last.bid_date = DateTime.now
    end

    Notification.send_message(@booking.creator.user, "#{@presenter.first_name} has expressed an interest in this booking.", "/bookings/#{@booking.id}")
    flash[:success] = "You have successfully placed a bid on this booking."
    redirect_to bookings_open_path
  end

  def choose_presenter
    @presenter = Presenter.find(params[:presenter_id])
    @presenter.bookings.each do |booking|
      if booking.creator == current_user.customer
        booking.chosen_presenter = @presenter
        booking.save
        Notification.send_message(@presenter.user, "You've been locked in for a booking!", "/bookings/#{booking.id}")
      end
    end
    flash[:success] = "#{@presenter.first_name} #{@presenter.last_name} has been assigned to this booking."
    
    redirect_to bookings_path
  end

  private
    def booking_params
      params.require(:booking).permit(:duration_minutes, :presenter_paid)
    end

    def admin_or_customer_logged_in
      if current_user.nil? || (current_user.user_type == "presenter") 
        flash[:danger] = "Only admin and customer are allowed to create a booking."
        redirect_to root_url        
      end
    end
end



