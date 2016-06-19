class Booking < ActiveRecord::Base
  acts_as_paranoid
  has_many :booked_customers, :dependent => :destroy
  has_many :customers, through: :booked_customers, :dependent => :destroy
  belongs_to :chosen_presenter, class_name: "Presenter"
  belongs_to :creator, class_name: "Customer"
  has_many :bids, :dependent => :destroy
  has_many :presenters, through: :bids, :dependent => :destroy
  belongs_to :subject, inverse_of: :bookings
  validates :booking_date, :presence => true
  validates :subject, :presence => true
  validates :cap, :presence => true
  validates :rate, numericality: true, :presence => true, :if => :booking_confirmed?
  validates :duration_minutes, numericality: true, :presence => true
  validate :booking_validation

  after_create :send_booking_reminder
  after_create :create_invoice  
 

  
  def self.help_required
    Booking.where('help_required = ? AND booking_date > ?', true, DateTime.now)
  end

  # Return upcoming booking for a customer or presenter
	# Return all upcoming bookings for an admin
  def self.upcoming(user)
  	# @user = User.check_user(user)
  	date_today = DateTime.now
    booking = nil
    # Refactored queries to not use select for possible performance improvements
  	if user.admin?
  		# return Booking.order(:booking_date).select{ |booking| booking.booking_date > date_today}
      return Booking.where('booking_date >= ?', date_today).order(:booking_date)
  	elsif user.presenter? # Add all booked then bids
      # return Booking.with_deleted.where(chosen_presenter: user.presenter).order(:booking_date).select{ |booking| booking.booking_date >= date_today}
      return Booking.where('booking_date >= ? AND chosen_presenter_id = ?', date_today, user.presenter).order(:booking_date)
    elsif user.customer?
      # return Booking.with_deleted.where(creator: user.customer).select{ |booking| booking.booking_date > date_today}
      return Booking.where('booking_date >= ?', date_today).order(:booking_date).select{ |booking| booking.creator == user.customer || booking.customers.includes?(user.customer)}
  	end
  	return nil
  end

  # Return past bookings for a customer or presenter
  # Return all past bookings for an admin
  def self.completed(user)
  	date_today = DateTime.now
    booking = nil
  	if user.presenter
  		return Booking.with_deleted.where('booking_date < ? OR deleted_at IS NOT NULL',date_today).where(chosen_presenter: user.presenter).order(:booking_date)
  	elsif user.customer
      return Booking.with_deleted.where('booking_date < ? OR deleted_at IS NOT NULL', date_today).order(:booking_date).select{ |booking| booking.creator == user.customer || booking.customers.includes?(user.customer)}
    else
      return Booking.with_deleted.order(created_at: :desc).select{ |booking| booking.booking_date < date_today}
  	end
  end

  def self.suggested(user)
    date_today = DateTime.now
    bookings = []
    if user.presenter?
      user.presenter.subjects.each do |subject|
        subject.bookings.each do |booking|
          if booking.chosen_presenter_id.nil? && (user.presenter.bids.empty? || booking.bids.empty?)
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

  # Removes chosen presenter from booking
  def remove_chosen_presenter
    self.chosen_presenter = nil
    self.save
  end
  # Deletes all bids placed on a booking. 
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
        if self.booking_date < Time.now
          return "Completed"
        else
          return "Locked in"
        end
      end
    end
  end

  # Get the total number of students in the booking
  def total_students
    students = 0
    self.booked_customers.each do |school|
      students += school.number_students
    end
    return students
  end

  def remaining_slots
    @count = 0
    self.booked_customers.each do |booked_customer|
      @count += booked_customer.number_students.to_i
    end
    return self.cap - @count

  end
  private
  def booking_validation
    unless chosen_presenter.nil?
      # check presenter teaches subject
      unless chosen_presenter.teaches? subject
        errors.add(:presenter, "does not teach this subject.")
      end
    end
    # check that booking date is in the future. 
    unless booking_date >= DateTime.now
      errors.add(:booking_date, "must be in the future.")
    end
    
    unless duration_minutes >= 0 
      errors.add(:duration, "must be greater than 0")
    end
  end

  def booking_confirmed?
    return !chosen_presenter.nil?
  end

  def send_booking_reminder
    @curr_date = Date.today
    @end_date = self.booking_date - 2.day
    @end_date = Date.parse(@end_date.strftime("%d/%m/%Y"))
    @period = (@end_date - @curr_date).to_i
    Resque.enqueue_in @period.day, BookingReminder, self.id
  end

  def create_invoice
    @curr_date = Date.today
    @end_date = Date.parse(self.booking_date.strftime("%d/%m/%Y"))
    @period = (@end_date - @curr_date).to_i
    Resque.enqueue_in @period.day, CreateInvoice, self.id
  end
end
