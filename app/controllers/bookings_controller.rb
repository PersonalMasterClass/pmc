class BookingsController < ApplicationController
  before_filter :admin_or_customer_logged_in, :except => [:index, :past, :show, :open, :set_bid, :cancel_bid]
  before_filter :admin_logged_in, :only => [:index]
  before_filter :logged_in, :only => [:past]
  #admin view for all bookings
  def index  
    @bookings = Booking.with_deleted
  end

  #shows all previous bookings for a user
  def past
    @bookings = Booking.completed(current_user)
  end

  def show
    @booking = Booking.with_deleted.find(params["id"])
    @creator = @booking.creator
  end
  def new_from_enquiry
    @enquiry = Enquiry.find(params[:id])
    if @enquiry.nil?
      redirect_to root_path
    end

    if @enquiry.accepted? && @enquiry.customer == current_user.customer
      @booking = Booking.new 
    else
      redirect_to enquiry_path(@enquiry)
    end
  end

  # Creates a new booking from an accepted enquiry
  def create_from_enquiry

    @booking = Booking.new(booking_params)
    @enquiry = Enquiry.find(params[:enquiry])
    unless params[:subject_id].empty?
      @subject = Subject.find(params[:subject_id].to_i) 
    end
    
    if @enquiry.nil?
      redirect_to root_path
    end
    
    if @enquiry.accepted? && current_user.customer == @enquiry.customer
      @booking.creator = @enquiry.customer
      @booking.chosen_presenter = @enquiry.presenter
      @booking.booking_date = DateTime.new(@enquiry.date.year, @enquiry.date.month, @enquiry.date.day, @enquiry.time.hour, @enquiry.time.min)
      @booking.rate = @enquiry.rate
      @booking.customers << current_user.customer
      @booking.booked_customers.first.number_students = params[:booking][:booked_customers][:number_students]
      @booking.subject = @subject
      if @booking.save
        @enquiry.update(:status => "booked")
        redirect_to @booking
        return
      else
        render action: 'new_from_enquiry'
      end
    else
      redirect_to root_path
      return
    end
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
    unless @date_part.nil?
      if @date_part.empty? && !params[:day].nil?
        begin
          @date_part = Date.parse(params[:day])
        rescue ArgumentError
        end
      end
    end
    unless @time_part.nil?
      if (@time_part.nil? || @time_part.empty?) && !params[:availability].nil?
        hr = (Availability.find(params[:availability]).start_time/60).to_s.rjust(2,'0')
        min = (Availability.find(params[:availability]).start_time%60).to_s.rjust(2,'0')
        @time_part = "#{hr}:#{min}"
      end
    end
  end

  def create
    @booking = Booking.new(booking_params)
    
    
    @subject = Subject.find(params[:subject_id])
    # TODO date and time validation
    date = (params['date_part'] + " " + params['time_part']).to_datetime
    @booking.booking_date = date
    # TODO: Refactor for admin booking creation
    @booking.shared = params["shared"]
    @booking.subject = @subject
    # Add this customer as owner. 
    @booking.creator = current_user.customer
    @booking.customers << current_user.customer
    @booking.booked_customers.first.number_students = params[:booking][:booked_customers][:number_students]
    @booking.period = 2
    if params[:rate].present?
      @booking.rate = params[:rate]
    end

    # Create closed booking if customer came from searching or enquiring.
    if session[:search_params].present? || params[:presenter_id].present?
      presenter = Presenter.find(params[:presenter_id])
      if presenter.available? @booking.booking_date, @booking.duration_minutes
        @booking.chosen_presenter = Presenter.find(params[:presenter_id])
        @booking.creator = current_user.customer
      else
        flash[:danger] = "Presenter is not available at this time."
        render :new
      end
    end   
    
    if @booking.save
      # Only send messages to customers if booking is shared
      @message = "A new #{@booking.subject.name} booking has been created that you may be interested in."
      if @booking.shared?
        Notification.notify_applicable_users(current_user, @booking, "customer", booking_path(@booking), @message, :interested_booking)
      end
      # Only send messages to presenters if booking is open
      if @booking.chosen_presenter.nil?
        Notification.notify_applicable_users(current_user, @booking, "presenter", booking_path(@booking), @message, :interested_booking)
      end
      Notification.notify_admin("A new booking has been created", booking_path(@booking), :booking)

      # Add booking to booked customers
      current_user.customer.created_bookings << @booking

      #clear search session 
      session[:search_params] = nil
      redirect_to @booking
    else
      render :new
    end

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
    
    if !@presenter.presenter_profile
      flash[:info] = "You must create your profile before you can do this"
      redirect_to edit_presenter_profile_path(@presenter) and return
    elsif @presenter.presenter_profile.bio.nil?
      flash[:info] = "You must wait for your profile to be approved before you can do this"
      redirect_to root_url and return
    end

    if @booking.presenters.include? @presenter
      flash[:info] = "You have already expressed interest in this booking"
      redirect_to root_url and return
    else
      @booking.presenters << @presenter
      @bid = @booking.bids.find_by(presenter: @presenter)
      @bid.bid_date = DateTime.now
      @bid.rate = params[:rate]
      @bid.save
    end

    Notification.send_message(@booking.creator.user, "#{@presenter.first_name} has expressed an interest in this booking.", booking_path(@booking), :bid)
    flash[:success] = "You have successfully placed a bid on this booking."
    redirect_to root_url
  end

  def choose_presenter
    @presenter = Presenter.find(params[:presenter_id])
    @booking = Booking.find(params[:booking_id])
    
    @booking.chosen_presenter = @presenter
    @booking.rate = @presenter.bids.find_by(booking: @booking).rate
    @booking.help_required = false
    @booking.save
    @booking.remove_all_bids

    Notification.send_message(@presenter.user, "You've been locked in for a booking!", booking_path(@booking), :choose_presenter)
    flash[:success] = "#{@presenter.get_private_full_name(current_user)} has been assigned to this booking."
    
    redirect_to root_path
  end
  # get_help allows a school to request help choosing a presenter for a booking
  # This action notifies the admin that a school has requested help, and updates the help_required flag.
  def get_help 
    @booking = Booking.find(params[:id])
    owner = @booking.creator
    Notification.notify_admin("#{owner.first_name} #{owner.last_name} has asked for help choosing a presenter for their booking", booking_path(@booking), :get_help)
    flash[:info] = "An admin has been notified that you would like help choosing. They will be in contact with you shortly"
    @booking.help_required = true
    @booking.save
    redirect_to booking_path(@booking)
  end
  # cancel_help allows a school or admin to dismiss the help requested flag for a booking. 
  def cancel_help
    booking = Booking.find(params[:id])
    flash[:info] = "Help no longer required"
    booking.help_required = false
    booking.save
    redirect_to booking_path(booking)
  end

  def join
    @booking = Booking.find(params[:id])
    if params[:num_students].to_i > @booking.remaining_slots
      flash[:danger] = "Oops! There is not enough room for the number of students you've specified."
      render :show
    else
      @booking.customers << current_user.customer
      @booked_customer = @booking.booked_customers.find_by(customer: current_user.customer)
      @booked_customer.number_students = params[:num_students]
      @booked_customer.save
      Notification.notify_admin("#{current_user.customer.first_name} of #{current_user.customer.school_info.school_name} has joined a booking.", booking_path(@booking), :join)
      Notification.send_message(@booking.creator.user, "A school has joined your booking.", booking_path(@booking), :join)
      flash[:success] = "Success! You've joined the booking!"
      redirect_to root_url
    end
  end

  def cancel_booking
    @booking = Booking.find(params[:id])
    if @booking.booking_date > Time.now
      if params[:cancellation_message].strip == "" || params[:cancellation_message].nil?
        flash[:danger] = "Message needs to be specified before cancelling a booking."
        redirect_to booking_path(@booking)
      else
        @booking.cancellation_message = params[:cancellation_message]
        @booking.save
        Notification.cancelled_booking(@booking, booking_path(@booking))
        @booking.destroy 
        flash[:success] = "Booking has been cancelled and potential participants notified!"
        redirect_to booking_path(@booking)
      end
    else
      flash[:danger] = "Booking cannot be cancelled as it has already been completed"
      redirect_to booking_path(@booking)
    end
  end

  def cancel_bid
    @booking = Booking.find(params[:id])
    @booking.presenters.delete(current_user.presenter)
    flash[:success] = "Success! You've withdrawn your bid."
    if @booking.presenters.count < 2
      @booking.help_required = false
      @booking.save
    end
    Notification.send_message(@booking.creator.user, "#{current_user.presenter.get_private_full_name(current_user)} has withdrawn their bid.", booking_path(@booking), :cancel_bid)
    redirect_to root_url
  end

  def leave_booking
    @booking = Booking.find(params[:id])
    @booking.customers.delete(current_user.customer)
    flash[:success] = "Success! You've left the booking."
    Notification.send_message(@booking.creator.user, "A school has left your booking.", booking_path(@booking), :leave_booking)
    redirect_to root_url
  end

  private
    def booking_params
      params.require(:booking).permit(:duration_minutes, :presenter_paid, :shared)
    end

    def admin_or_customer_logged_in
      if current_user.nil? || (current_user.user_type == "presenter") 
        flash[:danger] = "Only admin and customer are allowed to create a booking."
        redirect_to root_url        
      end
    end

    def admin_logged_in
      redirect_to root_url unless current_user.admin?
    end

    def logged_in
      redirect_to root_url unless current_user
    end 
end



