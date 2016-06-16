include ActionView::Helpers::SanitizeHelper

class PresenterProfilesController < ApplicationController
    skip_before_filter :profile_created?
    before_filter :correct_user, :only => [:new, :create]
    before_filter :admin_or_presenter_logged_in, :only => [:edit, :update]
    before_filter :logged_in_user, :only => [:show]
    before_filter :is_admin, :only => [:pending]
    after_filter :display_creator_actions, :only => [:show]

  # View Presenter Profile 
  def show
    @presenter = find_presenter
    @profile = @presenter.presenter_profile
    @user = @presenter.user
    @availability = @presenter.availabilitys.order('availabilities.start_time ASC')
    
    if !session[:search_params].nil?
      if current_user.customer? && session[:search_params].any?
        session[:presenter_id] = params["presenter_id"]
      end
    end
  end

  # Admin only view for all profile changes requiring approval
  def pending
    @unapproved_profiles = PresenterProfile.unapproved_profiles
    @draft_profiles = PresenterProfile.admin_drafts
    @profile_count = PresenterProfile.unapproved_profiles.count + PresenterProfile.admin_drafts.count
  end
  # Action for presenters to fill in their bio and upload profile pictures
  def new
    @help = PageContent.find_by_name("profile-help") # "What to include in profile" Content
    @presenter = find_presenter
    if @presenter.presenter_profile.nil?
      @presenter_profile = @presenter.build_presenter_profile(status: :new_profile)
    else
      redirect_to edit_presenter_profile_path(@presenter)
    end
  end

  def create
    @presenter = find_presenter
    if @presenter.presenter_profile.nil?
      new_profile = profile_params
      new_profile[:bio_edit] = sanitize_bio(new_profile[:bio_edit])
      @presenter_profile = @presenter.build_presenter_profile(new_profile)
      #submit to admin for approval
      if params[:submit]
        @presenter_profile.status = :pending_admin
        if @presenter_profile.save
          flash[:info] = "Profile submitted to admin for approval"
          notify_admin_profile_changes(@presenter)
          redirect_to root_url
        else
          render 'new'
        end
      #save draft
      else
        @presenter_profile.status = :new_profile
        if @presenter_profile.save
          flash[:info] = "Profile draft saved. Go to edit profile to continue editing."
          redirect_to root_url
        else
          render 'new'
        end
      end
    else
      redirect_to edit_presenter_profile_path(@presenter)
    end 
  end

  # Edit profile action for both presenters and admin
  def edit
    @help = PageContent.find_by_name("profile-help") # "What to include in profile" Content
    @presenter = find_presenter
    @presenter_profile = @presenter.presenter_profile
    if @presenter_profile.nil?
      redirect_to new_presenter_profile_path(@presenter)
    end
    #displays current profile information for editing 
    if !@presenter_profile.bio_edit.nil?
      if @presenter_profile.approved? && @presenter_profile.bio_edit.empty?
        @presenter_profile.bio_edit = @presenter_profile.bio
      end
    else
      if @presenter_profile.approved?
        @presenter_profile.bio_edit = @presenter_profile.bio
      end
    end
  end
  
  # Update profile action for both presenters and admin
  def update
    @presenter = find_presenter
    @presenter_profile = @presenter.presenter_profile
    
    if @presenter_profile.nil?
      redirect_to new_presenter_profile_path(@presenter)
    else
      new_profile = profile_params
      new_profile[:bio_edit] = sanitize_bio(new_profile[:bio_edit])
      if !new_profile.has_key?(:picture_edit)
        new_profile[:picture_edit] = nil
      end
      #submit for approval
      if params[:submit]
        if @presenter_profile.update(new_profile)
          #checks profile has been changed
          if @presenter_profile.bio != @presenter_profile.bio_edit || @presenter_profile.picture_edit_stored?
            if current_user.user_type == "admin"
              @presenter_profile.update_attribute(:status, :pending_presenter)
              flash[:info] = "Profile changes submitted to presenter for approval"
              Notification.send_message(@presenter.user, "You have pending profile changes to review from an Admin", presenter_profile_path(@presenter), :system)
              redirect_to admin_path
            else #current user is profile owner
              @presenter_profile.update_attribute(:status, :pending_admin)
              flash[:info] = "Profile changes submitted to admin for approval"
              notify_admin_profile_changes(@presenter)
              redirect_to root_url
            end
          else # No changes were made
            @presenter_profile.bio_edit = ''
            @presenter_profile.picture_edit = nil
            flash[:warning] = 'No changes were made, please make changes before pressing submit'
            redirect_to edit_presenter_profile_path(@presenter)
          end
        else
          render 'edit'
        end
      #save draft
      elsif params[:save]
        if @presenter_profile.update(new_profile)
          if current_user.presenter?
            @presenter_profile.update_attribute(:status, :draft_presenter)
            flash[:info] = "Profile draft saved. Go to edit profile to continue editing."
            redirect_to presenters_path
          else #current_user.admin?
            @presenter_profile.update_attribute(:status, :draft_admin)
            flash[:info] = "Profile draft saved for #{@presenter.first_name}'s profile."
            redirect_to admin_path
          end
        else
          render 'edit'
        end
      end
    end
  end

  def destroy
  end

  # Action to approve changes to a presenters profile
  # Used by both presenters and admin
  def approve
    #get profile, and profile owner
    presenter = find_presenter
    profile = presenter.presenter_profile
    
    #check status of profile
    #if waiting for admin approval
    if profile.status == "pending_admin"
      #check if logged in user is an admin
      if current_user.user_type == "admin"
        if profile.approve
          flash[:info] = "This profile has been approved"
          Notification.send_message(presenter.user, "Your profile changes have been approved.", presenter_profile_path(presenter), :system)
          redirect_to presenter_profile_path(presenter)
        else
          flash[:danger] = "Something went wrong"
          redirect_to presenter_profile_path(presenter)
        end
        
      else #Incorrect user
        flash[:info] = "Profile changes are waiting for approval from admin."
        redirect_to root_url
      end

    #if waiting for profile owner approval
    elsif profile.status == "pending_presenter"
      #check if logged in presenter is profile owner
      if presenter == current_user.presenter
        if profile.approve
          flash[:info] = "Your profile has been approved"
          redirect_to presenter_profile_path(presenter)
        else
          flash[:danger] = "Something went wrong"
          redirect_to presenter_profile_path(presenter)
        end
      else #incorrect user
        flash[:info] = "Profile changes are waiting approval from presenter"
        redirect_to presenter_profile_path(presenter)
      end

    else #profile is already approved
      flash[:warning] = "Profile is already approved"
      redirect_to root_url
    end
  end

 

  private

    #sanitizes bio input from users to ensure it is safe
    def sanitize_bio(bio)
      permit_scrubber = Rails::Html::PermitScrubber.new
      permit_scrubber.tags = %w(h3 h4 p ul li ol strong em span sup sub)
      sanitize bio, tags:  %w(h3 h4 p ul li ol strong em span sup sub), scrubber: permit_scrubber
    end

    def profile_params
      params.require(:presenter_profile).permit(:bio_edit, :picture_edit)
    end

    def find_presenter
      Presenter.find(params[:presenter_id])
    end
    # Sends Admin notification of a changed profile. 
    def notify_admin_profile_changes(presenter)
      Notification.notify_admin("#{presenter.first_name} #{presenter.last_name} has submitted a profile for approval", presenter_profile_path(presenter), :system)
    end

    #before filters

    #checks current user if profile owner
    def correct_user
      unless Presenter.find_by(user_id: current_user) == find_presenter
        if current_user.admin?
          redirect_to edit_presenter_profile_path
        else
          flash[:danger] = "Unauthorized Access"
          redirect_to root_url
        end 
      end
    end

    #ensures only admin and profile owner can edit profile
    #and that a presenter/admin can only edit at the correct time
    def admin_or_presenter_logged_in
      presenter = find_presenter
      profile = presenter.presenter_profile

      if current_user.nil? || (!current_user.admin? && Presenter.find_by(user_id: current_user) != presenter)
        flash[:danger] = "Unauthorized Access"
        redirect_to root_url
      #presenter has already submitted to admin for approval
      elsif Presenter.find_by(user_id: current_user) == presenter && profile.pending_admin?
        flash[:info] = "Cannot modify profile at this time. You already have changes waiting on admin actions."
        redirect_to presenter_profile_path(presenter)
      #admin has already submitted to presenter for approval
      elsif current_user.admin? && profile.pending_presenter?
        flash[:info] = "Cannot modify profile at this time. This profile is waiting on presenter actions."
        redirect_to presenter_profile_path(presenter)
      end
    end
    
    def logged_in_user
      if current_user.nil?
       flash[:danger] = "You must be logged in to view profiles"
       redirect_to root_url
      else
        if current_user.presenter?
          redirect_to root_url unless current_user.presenter == find_presenter
        end
      end
    end

    def is_admin
      redirect_to root_url unless current_user.user_type == 'admin'
    end

    def display_creator_actions
      @display_creator_actions = Booking.check_creator(@presenter, current_user.customer)
    end
end
