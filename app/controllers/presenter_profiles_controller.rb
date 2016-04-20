class PresenterProfilesController < ApplicationController
    before_filter :correct_user, :only => [:new, :create]
    before_filter :admin_or_presenter_logged_in, :only => [:edit, :update]
    before_filter :logged_in_user, :only => [:show]
    before_filter :is_admin, :only => [:pending]

  def show
    @presenter = find_presenter
    @user = @presenter.get_user
  end

  def pending
    @profiles = PresenterProfile.unapproved_profiles
    @profile_count = PresenterProfile.unapproved_profiles.count
  end

  def new
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
      @presenter_profile = @presenter.build_presenter_profile(profile_params)
      @presenter_profile.status = :pending_admin
      if @presenter_profile.save
        flash[:info] = "Profile submitted to admin for approval"
        redirect_to presenters_path
      else
        render 'new'
      end
    else
      redirect_to edit_presenter_profile_path(@presenter)
    end 
  end

  def edit
    @presenter = find_presenter
    @presenter_profile = @presenter.presenter_profile
    if @presenter_profile.nil?
      redirect_to new_presenter_profile_path(@presenter)
    end
    #displays current profile information for editiong 
    if @presenter_profile.status == "approved"
      @presenter_profile.bio_edit = @presenter_profile.bio
      @presenter_profile.picture_edit = @presenter_profile.picture
    end
  end

  def update
    @presenter = find_presenter
    @presenter_profile = @presenter.presenter_profile
    
    if @presenter_profile.nil?
      redirect_to new_presenter_profile_path(@presenter)
    else
      #logic for admin's editing a users profile
      if current_user.user_type == "admin"
        if @presenter_profile.update_attributes(profile_params)
          @presenter_profile.update_attribute(:status, :pending_presenter)
          flash[:info] = "Profile changes submitted to presenter for approval"
          redirect_to presenters_path
        else
          render 'edit'
        end

      else #current_user is profile owner
        if @presenter_profile.update_attributes(profile_params)
          @presenter_profile.update_attribute(:status, :pending_admin)
          flash[:info] = "Profile changes submitted to admin for approval"
          redirect_to presenters_path
        else
          render 'edit'
        end
      end
    end
  end

  def destroy
  end

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
          #TODO: send notification to presenter
          redirect_to presenter_profile_path(presenter)
        else
          flash[:danger] = "Something went wrong"
          redirect_to presenter_profile_path(presenter)
        end
        
      else
        flash[:info] = "Profile changes are waiting for approval from admin."
        redirect_to root_url
      end

    #if waiting for profile owner approval
    elsif profile.status == "pending_presenter"
      #check if logged in presenter is profile owner
      if presenter == Presenter.find_by(user_id: current_user)
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
    def profile_params
      params.require(:presenter_profile).permit(:bio_edit, :picture_edit)
    end

    def find_presenter
      Presenter.find(params[:presenter_id])
    end

    #before filters

    #checks current user if profile owner
    def correct_user
      unless Presenter.find_by(user_id: current_user) == find_presenter
        flash[:danger] = "Unauthorized Access"
        redirect_to root_url 
      end
    end

    #ensures only admin and profile owner can edit profile
    def admin_or_presenter_logged_in
      #Cant refactor to Presenter.find(current_user), it searches for Presenter that matches the user id, not the presenter id. 
      if current_user.nil? || (current_user.user_type != "admin" && Presenter.find_by(user_id: current_user) != find_presenter)
        flash[:danger] = "Unauthorized Access"
        redirect_to root_url        
      end
    end

    def logged_in_user
      if current_user.nil?
       flash[:danger] = "You must be logged in to view profiles"
       redirect_to root_url
      end
    end

    def is_admin
      redirect_to root_url unless current_user.user_type == 'admin'
    end
end
