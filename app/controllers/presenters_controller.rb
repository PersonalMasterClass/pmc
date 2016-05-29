class PresentersController < ApplicationController

	def index
    @presenter = current_user.presenter
    @upcoming = Booking.upcoming(current_user) 
    @bookings = Booking.suggested(current_user)
    @bids = current_user.presenter.bids
	end
	
  def new
  end

  def create
  end

  # list current profiles and provide CrUD like interface. 
  def edit_subjects
  	@presenter = current_user.presenter
  end

  def rate
  end
  def set_rate
    @presenter = current_user.presenter
    @presenter.rate = params[:rate]
    @presenter.save(:validate => false)
    flash[:success] = "You have set your base rate to $#{@presenter.rate}"
    redirect_to presenters_path
  end

  # add a subject to the presenter's subject
  def add_subject
  	@subject = Subject.find_by(name: params[:subjects][:name])
  	unless current_user.presenter.subjects.include?(@subject)
      current_user.presenter.subjects << @subject 
    end
  	redirect_to presenter_edit_subjects_path
  end

  def remove_subject
    @subject = Subject.find(params[:subject])
    @subject.presenters.delete(current_user.presenter)
    redirect_to presenter_edit_subjects_path
  end

  def edit_details 
    @presenter_id = current_user.presenter
    @presenter = Presenter.find(@presenter_id)
  end

  def update_details
    @presenter = current_user.presenter
    @presenter.school_info = SchoolInfo.find(params[:school_id])
    if @presenter.update(presenter_update_params)
      redirect_to root_url
    else
      render 'edit_details'
    end
  end

private
  def presenter_update_params
    params.require(:presenter).permit(:first_name, :last_name, :phone_number, :vit_number, :department, :contact_title, 
                                       :school_id)

  end

def has_access
      redirect_to root_url unless (current_user.user_type == 'admin' || current_user.presenter == Presenter.find(params[:id]))
    end

end
