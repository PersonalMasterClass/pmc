class PresenterProfile < ActiveRecord::Base
  belongs_to :presenter
  
  #TODO: add validation 
  
  # table columns
  # => :bio, :bio_edit, :status, :picture, :picture_edit, :presenter

  enum status: [:new_profile, :pending_admin, :pending_presenter, :approved]

  def self.unapproved_profiles
    PresenterProfile.where('status= ?', 1)
  end

end
