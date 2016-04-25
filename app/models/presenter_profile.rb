class PresenterProfile < ActiveRecord::Base
  belongs_to :presenter
  

  #TODO: add validation 
  
  # table columns
  # => :bio, :bio_edit, :status, :picture, :picture_edit, :presenter

  enum status: [:new_profile, :pending_admin, :pending_presenter, :approved]

  def self.unapproved_profiles
    PresenterProfile.where('status= ?', 1)
  end

  def approve
    if self.status == "pending_presenter" || self.status == "pending_admin"
      
      #move edit columns to permanent columns
      self.bio = self.bio_edit
      self.picture = self.picture_edit
      
      #clear edit columns
      self.bio_edit = ''
      self.picture_edit = ''
      
      #update status to approved
      self.status = :approved
      return self.save
    else
      return false
    end
  end
end
