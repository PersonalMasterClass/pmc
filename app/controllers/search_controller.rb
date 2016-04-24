class SearchController < ApplicationController

	 def index 
  	@search_params = params

	 	@presenter, subjectArr, dateArr, name = [],[], [], []
	 	
    if any_present
	    unless !@search_params[:subject_id] || @search_params[:subject_id].empty?
	      begin
	        subj = Subject.find(@search_params[:subject_id])
	        @search_params[:subject_name] = subj.name
	        subjectArr = by_subject(subj)
	      rescue ActiveRecord::RecordNotFound
	      end
	    end
	    # unless subject.empty?
	    	@presenter =  subjectArr & by_date
	  
	  end
	  
	  
  end

  private

  # Check anything has been entered
	  def any_present
	    return !(params[:subject_id].blank? && params[:date_part].blank? && 
	    	params[:time_part].blank? && params[:first_name].blank?)
	  end

	  # Find presenters based on subject
	  def by_subject(subject)
	  	return subject.presenters
	  end

	  # Find users based on availability
	  def by_date()
	  	unless !@search_params[:time_part] || @search_params[:time_part].empty?
	  		x = @search_params[:time_part].split(':')
 				time = x[0].to_i * 60 + x[1].to_i
	  		presenters = []

	  		# Query logic: time needs to between start and end time unless end time is < 
	  		# start time which indicates the availability extends past midnight. 
	  		Availability.where("(end_time > start_time AND start_time <= #{time} and end_time >= #{time}) OR (#{time} >= end_time AND #{time} >= start_time)").each do |a|
	  			presenters << a.presenter
	  		end
	  		return presenters
	  	end
	  end
	  	
end
