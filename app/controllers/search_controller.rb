class SearchController < ApplicationController

	 def index 
    	@search_params = params
	 	
    if any_present
	    unless !@search_params[:subject_id] || @search_params[:subject_id].empty?
	      begin
	        subject = Subject.find(@search_params[:subject_id])
	        @search_params[:subject_name] = subject.name
	        @presenter = by_subject(subject)
	      rescue ActiveRecord::RecordNotFound
	      end
	    end
	  end
  end

  private

  # Check anything has been entered
	  def any_present
	    return !(params[:subject_id].blank? && params[:date_part].blank? && 
	    	params[:time_part].blank? && params[:first_name].blank?)
	  end

	  def by_subject(subject)
	  	return subject.presenters
	  end

end
