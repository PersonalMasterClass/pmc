class Booking < ActiveRecord::Base
  acts_as_paranoid
  has_many :booked_customers
  has_many :customers, through: :booked_customers
  belongs_to :chosen_presenter, class_name: "Presenter"
  belongs_to :creator, class_name: "Customer"
  has_many :bids
  has_many :presenters, through: :bids
  belongs_to :subject, inverse_of: :bookings

  # Return upcoming booking for a customer or presenter
	# Return all upcoming bookings for an admin
  def self.upcoming(user)
  	@user = User.check_user(user)
  	date_today = DateTime.now
  	if @user.nil?
  		return Booking.all.select{ |booking| booking.booking_date > date_today}
  	else
  		return @user.bookings.select{ |booking| booking.booking_date > date_today}
  	end
  	return false
  end

  # Return completed bookings for a customer or presenter
  # Return all completed bookings for an admin
  def self.completed(user)
  	@user = User.check_user(user)
  	date_today = DateTime.now
  	if @user.nil?
  		return Booking.all.select{ |booking| booking.booking_date < date_today}
  	else
  		return @user.bookings.select{ |booking| booking.booking_date < date_today}
  	end
  end

  def self.suggested(user)
    @user = User.check_user(user)
    booking = nil
    @user.subjects.each do |subject|
      if booking.present?
        booking  << Booking.joins(:subject).where(subjects: {name: subject.name})
      else
        booking = Booking.joins(:subject).where(subjects: {name: subject.name}) 
      end
    end
    return booking
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

  #Removes chosen presenter from booking and notifies creator of that booking
  def remove_chosen_presenter
    self.chosen_presenter = nil
    self.save
  end

  def remove_all_bids
    Bid.where(booking_id: self).delete_all
  end
end
