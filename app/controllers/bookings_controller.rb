class BookingsController < ApplicationController
  before_filter :admin_or_customer_logged_in, :except => [:index, :show]
  def index
  end

  def show
    @booking = Booking.find(params["id"])
  end

  def new
    @booking = Booking.new
  end

  def create
    @booking = Booking.new(booking_params)
   # TODO: Refactor for admin booking creation
    @booking.save
    
    current_user.customer.bookings << @booking
    redirect_to @booking

  end

  def edit
  end

  def update
  end

  def destroy
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



