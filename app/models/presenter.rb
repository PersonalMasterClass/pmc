class Presenter < ActiveRecord::Base
	belongs_to :school_info
  belongs_to :user, inverse_of: :presenter
  has_one :presenter_profile, dependent: :destroy
  has_many :availabilitys
  has_and_belongs_to_many :subjects
  has_many :bids
  has_many :bookings, through: :bids

	validates :first_name, :last_name, :school_info, presence: true
  validates :vit_number, format: /\A^\d{6}$\Z/
  validate :vit_number_must_be_valid
  validates :phone_number, format: /\A^(?:\+?61|0)[2-4578](?:[ -]?[0-9]){8}$\Z/, presence: true
  validates :rate, numericality: true

  def vit_number_must_be_valid
    unless VitValidation.check_vit(first_name, last_name, vit_number)
      errors.add(:vit_number, "could not be found on the vit register.")
    end
  end


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

  def get_private_full_name(user)
    if user.admin? || user == self.user
      return "#{self.first_name} #{self.last_name}"
    else
      return "#{self.first_name} #{self.last_name.at(0)}"
    end      
  end

  def remove_upcoming_bookings
    bookings = Booking.upcoming(self.user)
    if bookings.present?
      bookings.each do  |booking|
        if booking.remove_chosen_presenter == self
          booking.remove_chosen_presenter
          Notification.send_message(booking.creator.user, "The presenter for this booking are now unavailable", booking_path(booking))
        end
      end
    end
  end

  def remove_all_bids
    Bids.where(presenter_id: self).delete_all
  end

end
