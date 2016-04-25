class BookingsController < ApplicationController
  before_filter :admin_or_customer_logged_in, :except => [:index, :show, :open, :bid]

  def index
    @upcoming = Booking.upcoming(current_user) 
    @completed = Booking.completed(current_user)
  end

  def show
    @booking = Booking.find(params["id"])
  end

  def new
    @booking = Booking.new
    @date_part
    @time_part
  end

  def create
    @booking = Booking.new(booking_params)
    @subject = Subject.find(params[:subject_id])
    # TODO date and time validation
    date = (params['date_part'] + " " + params['time_part']).to_datetime
    @booking.booking_date = date
    # TODO: Refactor for admin booking creation
    
    @booking.subject = @subject
    # Add this customer as owner. 
    @booking.creator = current_user.customer


    @booking.save

    Notification.notify_applicable_presenters(@booking.subject)

    # Add booking to booked customers
    current_user.customer.bookings << @booking

    redirect_to @booking

  end

  def edit
  end

  def update
  end

  def destroy
  end

  def open
    @bookings = Booking.where(shared: true)
  end

  def bid
    @booking = Booking.find(params[:id])
    @presenter = current_user.presenter
    # This will create a bi directional association, @booking will contain @presenter as well.
    @presenter.bookings << @booking
    @presenter.bids.last.bid_date = DateTime.now
    flash[:success] = "You have successfully placed a bid on this booking."
    redirect_to bookings_open_path
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



