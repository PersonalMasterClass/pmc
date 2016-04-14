class PresenterProfilesController < ApplicationController
    before_filter :correct_user, :only => [:new, :create]
    before_filter :admin_or_presenter_logged_in, :only => [:edit, :update]

  def new
    @presenter = find_presenter
    if @presenter.presenter_profile.nil?
      @presenter_profile = @presenter.build_presenter_profile(status: :new_profile)
    else
      redirect_to edit_presenter_presenter_profile_path(@presenter)
    end
  end

  def create
    @presenter = find_presenter
    if @presenter.presenter_profile.nil?
      @presenter_profile = @presenter.build_presenter_profile(profile_params)
      @presenter_profile.status = :pending_admin
      if @presenter_profile.save
        flash[:info] = "Profile submitted to admin for approval"
        redirect_to root_url
      else
        render 'new'
      end
    else
      redirect_to edit_presenter_presenter_profile_path(@presenter)
    end 
  end

  def edit
    @presenter = find_presenter
    @presenter_profile = @presenter.presenter_profile
    if @presenter_profile.nil?
      redirect_to new_presenter_presenter_profile_path(@presenter)
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
      redirect_to new_presenter_presenter_profile_path(@presenter)
    else
      #logic for admin's editing a users profile
      if current_user.user_type == "admin"
        if @presenter_profile.update_attributes(profile_params)
          @presenter_profile.update_attribute(:status, :pending_presenter)
          flash[:info] = "Profile changes submitted to presenter for approval"
          redirect_to root_url
        else
          render 'edit'
        end

      else #current_user is profile owner
        if @presenter_profile.update_attributes(profile_params)
          @presenter_profile.update_attribute(:status, :pending_admin)
          flash[:info] = "Profile changes submitted to admin for approval"
          redirect_to root_url
        else
          render 'edit'
        end
      end
    end
  end

  def destroy
  end

  def approve
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
      unless current_user.presenter == find_presenter
        flash[:danger] = "Unauthorized Access"
        redirect_to root_url 
      end
    end

    #ensures only admin and profile owner can edit profile
    def admin_or_presenter_logged_in

      if current_user.nil? || (current_user.user_type != "admin" && Presenter.find(current_user) != find_presenter)
        flash[:danger] = "Unauthorized Access"
        redirect_to root_url        
      end
    end
end
