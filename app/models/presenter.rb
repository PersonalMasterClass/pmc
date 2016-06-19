class Presenter < ActiveRecord::Base

  # Associations
	belongs_to :school_info
  belongs_to :user, inverse_of: :presenter
  has_one :presenter_profile, dependent: :destroy
  has_many :availabilitys
  has_and_belongs_to_many :subjects
  has_many :bids
  has_many :bookings, through: :bids
  has_many :enquiries
  has_many :customers, through: :enquiries

  # Validations
	validates :first_name, :last_name, :school_info, presence: true
  validates :vit_number, format: /\A^\d{6}$\Z/
  validate :vit_number_must_be_valid
  validates :phone_number, format: /\A^(?:\+?61|0)\s?[2-4578](?:[ -]?[0-9]){8}$\Z/, presence: true
  validates :rate, numericality: true, allow_nil: true
  
  after_create :add_to_xero
  after_update :update_xero

  # Validate presenter's VIT number
  def vit_number_must_be_valid
    unless VitValidation.check_vit(first_name, last_name, vit_number)
      errors.add(:vit_number, "could not be found on the VIT register.")
    end
  end


  #returns the path of a users profile picture depending on whether a profile
  #has been created and what enviroment the application is running on
  def profile_picture_path(size = '100x100#')
    if self.presenter_profile.nil?
      return Dragonfly.app.fetch_file('public/images/default-user-display.png').thumb(size).url
    else
      if Rails.env.development? || Rails.env.test?
        return self.presenter_profile.picture.thumb(size).url
      else
        return self.presenter_profile.picture.thumb(size).remote_url
      end
    end
  end


  #for a given user, returns the name of the presenter, if the user is a customer, then
  #the the last name is initialized for privacy.
  def get_private_full_name(user)
    if user.nil?
      return "#{self.first_name} #{self.last_name.at(0)}"
    elsif user.admin? || user == self.user
      return "#{self.first_name} #{self.last_name}"
    else
      return "#{self.first_name} #{self.last_name.at(0)}"
    end      
  end
  # check if a presenter teaches a subject
  def teaches? (subject)
    return self.subjects.exists? subject
  end
  # send updated peresnter details to Xero
  def update_xero
    Xero.update_presenter_account(self)
  end

  # add new presenter to Xero
  def add_to_xero
    Xero.add_presenter_account(self)
  end

  # Check presenter availabilities and bookings for clashes 
  def available?(date_time, duration=0)
    day = date_time.strftime("%A").downcase
    time = (date_time.strftime("%k").to_i * 60) + date_time.strftime("%M").to_i
    all_avals = Availability.where("#{day} = true AND start_time <= #{time} AND end_time >= #{time} AND presenter_id = #{self.id}")
    all_avals = all_avals.reject{|a| a.presenter != self}

    bkgs = Booking.where("chosen_presenter_id = #{self.id} AND booking_date >= '#{date_time.to_s(:db)}' AND booking_date <= '#{(date_time+duration.minutes).to_s(:db)}'")
    return !all_avals.empty? && bkgs.empty?
  end

  #removes all upcoming bookings for a presenter. 
  def remove_upcoming_bookings
    bookings = Booking.upcoming(self.user)
    if bookings.present?
      bookings.each do  |booking|
        if booking.remove_chosen_presenter == self
          booking.remove_chosen_presenter
          Notification.send_message(booking.creator.user, "The presenter for this booking are now unavailable", booking_path(booking), :booking)
        end
      end
    end
  end

  #Removes all booking bids the presenter has submitted
  def remove_all_bids
    Bid.where(presenter_id: self).delete_all
  end

  #Returns string for view depending on status 
  def profile_status_message
    profile = self.presenter_profile
    if profile == nil
      "No profile created"
    else
      if profile.pending_admin?
        "Pending Approval"
      elsif profile.draft_admin?
        "Draft Saved"
      elsif profile.pending_presenter?
        "Pending Approval"
      elsif profile.draft_presenter?
        "Draft Saved"
      else
        ""
      end
    end
  end

end
