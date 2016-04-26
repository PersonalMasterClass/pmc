class PresenterProfile < ActiveRecord::Base
  belongs_to :presenter
  
  dragonfly_accessor :picture do
    default 'public/images/default-user-display.png'
  end
  dragonfly_accessor :picture_edit

  #TODO: add validation 
  
  # table columns
  # => :bio, :bio_edit, :status, :presenter, 
  # dragonfly magic columns: :picture_uid, :picture_edit_uid, 

  enum status: [:new_profile, :pending_admin, :pending_presenter, :approved]

  def self.unapproved_profiles
    PresenterProfile.where('status= ?', 1)
  end

  def approve
    if self.status == "pending_presenter" || self.status == "pending_admin"
      
      #move edit columns to permanent columns
      self.bio = self.bio_edit
      if self.picture_edit_stored?
        self.picture = self.picture_edit
      end

      #clear edit columns
      self.bio_edit = ''
      self.picture_edit = nil
      
      #update status to approved
      self.status = :approved
      return self.save
    else
      return false
    end
  end

  def approved?
    self.status == "approved"
  end

end
