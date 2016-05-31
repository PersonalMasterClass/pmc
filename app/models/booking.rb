class Booking < ActiveRecord::Base
  acts_as_paranoid
  has_many :booked_customers, :dependent => :destroy
  has_many :customers, through: :booked_customers, :dependent => :destroy
  belongs_to :chosen_presenter, class_name: "Presenter"
  belongs_to :creator, class_name: "Customer"
  has_many :bids, :dependent => :destroy
  has_many :presenters, through: :bids, :dependent => :destroy
  belongs_to :subject, inverse_of: :bookings

  after_create :send_booking_reminder


  def self.help_required
    Booking.where('help_required = ? AND booking_date > ?', true, DateTime.now)
  end

  # Return upcoming booking for a customer or presenter
	# Return all upcoming bookings for an admin
  def self.upcoming(user)
  	# @user = User.check_user(user)
  	date_today = DateTime.now
    booking = nil
  	if user.admin?
  		return Booking.order(created_at: :desc)
  	elsif user.presenter? # Add all booked then bids
      return booking = Booking.where(chosen_presenter_id: user.id).select{ |booking| booking.booking_date > date_today}
    elsif user.customer?
      return Booking.where(creator: user.customer).select{ |booking| booking.booking_date > date_today}
  	end
  	return nil
  end

  # Return completed bookings for a customer or presenter
  # Return all completed bookings for an admin
  def self.completed(user)
  	date_today = DateTime.now
    booking = nil
  	if @user.presenter?
  		return @user.presenter.bookings.with_deleted.order(created_at: :desc).select{ |booking| booking.booking_date < date_today}
  	elsif @user.customer?
  		return @user.customer.bookings.with_deleted.order(created_at: :desc).select{ |booking| booking.booking_date < date_today}
  	end
  end

  def self.suggested(user)
    date_today = DateTime.now
    bookings = []
    if user.presenter?
      user.presenter.subjects.each do |subject|
        subject.bookings.each do |booking|
          if user.presenter.bids.empty? || booking.bids.empty?
            bookings << booking
          else
            booking.bids.each do |bid|
              if bid.presenter != user.presenter && booking.chosen_presenter_id.nil?
                if booking.booking_date > date_today 
                  bookings << booking
                end
              end
            end
          end
        end
      end
    elsif user.customer?
      user.customer.subjects.each do |subject|
        subject.bookings.each do |booking|
          if !booking.customers.include?(user.customer) && booking.creator != user.customer && booking.shared? 
            if booking.booking_date > date_today && booking.remaining_slots != 0
              bookings << booking
            end
          end
        end
      end
    end
    return bookings
  end
  def self.check_creator(presenter, creator)
    if presenter.bookings.present?
      presenter.bookings.each do |booking|
        if booking.creator == creator
          return true
        end
      end
    end
    return false
  end

  # View all upcoming shared bookings that a school has joined
  def self.joined_bookings(customer)
    bookings = []
    date_today = DateTime.now
    customer.subjects.each do |subject|
      subject.bookings.each do |booking|
        if booking.customers.include?(customer) && booking.creator != customer
          if booking.booking_date > date_today
            bookings << booking
          end
        end
      end
    end
    return bookings
  end

  #Removes chosen presenter from booking and notifies creator of that booking
  def remove_chosen_presenter
    self.chosen_presenter = nil
    self.save
  end

  def remove_all_bids
    Bid.where(booking_id: self).delete_all
  end

  def invoice!
    if self.chosen_presenter && self.rate 
      Xero.invoice_booking(self)
    end
  end


  #Returns a status message depending on the booking information
  def status_message
    if self.deleted_at
      return "Cancelled"
    else
      if self.chosen_presenter == nil
        if self.help_required
          return "Help Required"
        elsif self.presenters.present?
          return "Bids Pending"
        else
          return "Awaiting Bids"
        end
      else
        return "Locked in"
      end
    end
  end

  def remaining_slots
    @count = 0
    self.booked_customers.each do |booked_customer|
      @count += booked_customer.number_students 
    end
    return self.cap - @count
  end
  private
  def send_booking_reminder
    @curr_date = Date.today
    @end_date = self.booking_date - self.period.days
    @end_date = Date.parse(@end_date.strftime("%d/%m/%Y"))
    @period = (@end_date - @curr_date).to_i
    Resque.enqueue_in @period.day, BookingReminder, self.id
  end
end
