class PresenterProfile < ActiveRecord::Base

  # Associations
  belongs_to :presenter

  # Validations
  validates :bio_edit, length: { maximum: 5000 }
  validates_size_of :picture_edit, maximum: 10.megabytes
  validates_property :format, of: :picture_edit, in: ['jpeg', 'png',]
  validates_property :ext, of: :picture_edit, in: ['jpeg', 'png', 'JPEG', 'jpg', 'JPG', 'PNG']
  
  dragonfly_accessor :picture do
    default 'public/images/default-user-display.png'
  end
  dragonfly_accessor :picture_edit
  
  # table columns
  # => :bio, :bio_edit, :status, :presenter, 
  # dragonfly magic columns: :picture_uid, :picture_edit_uid, 

  enum status: [:new_profile, :pending_admin, :pending_presenter, :approved, :draft_admin, :draft_presenter]

  # Returns all profiles awaiting admin approval that do not belong to a suspended user. 
  def self.unapproved_profiles
    PresenterProfile.joins(presenter: :user).where.not(:users => {:status => 2}, :presenter_profiles => {:status => [0,2,3,4,5]})
  end
  # Returns all profiles drafts saved by an admin that do not belong to a suspended user. 
  def self.admin_drafts
    PresenterProfile.joins(presenter: :user).where.not(:users => {:status => 2}, :presenter_profiles => {:status => [0,1,2,3,5]})
  end

  # Gets profiles awaiting admin approval or submission as long as the presenter is not suspended
  def self.drafts_and_unapproved
    PresenterProfile.joins(presenter: :user).where.not(:users => {:status => 2}, :presenter_profiles => {:status => [0,2,3,5]})
  end

  # This method takes care of the process of updating the live profile with the new profile changes. 
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

end
