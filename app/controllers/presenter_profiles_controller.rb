class PresenterProfilesController < ApplicationController
  #TODO: before filters

  def new
    @presenter = findPresenter
    if @presenter.presenter_profile.nil?
      @presenter_profile = @presenter.build_presenter_profile(status: :new_profile)
    else
      redirect_to edit_presenter_presenter_profile_path(@presenter)
    end
  end

  def create
    @presenter = findPresenter
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
  end

  def update
  end

  def destroy
  end

  private
    def profile_params
      params.require(:presenter_profile).permit(:bio_edit, :picture_edit)
    end

    def findPresenter
      Presenter.find(params[:presenter_id])
    end
end
