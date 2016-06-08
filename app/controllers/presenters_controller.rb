class PresentersController < ApplicationController
  skip_before_filter :profile_created?
	def index
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
  	@subject = Subject.find_by_name(params[:name])
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

end
