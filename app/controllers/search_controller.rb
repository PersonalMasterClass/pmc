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
	      	@search_params[:subject_id] = nil
	      end
	    end
	    	@presenter = [subjectArr, by_time, by_day].reject
	    	




	    	binding.pry

	    	
	  end	  
  end

  private

  # Check if anything has been entered
	  def any_present
	    return !(params[:subject_id].blank? && params[:date_part].blank? && 
	    	params[:time_part].blank? && params[:first_name].blank?)
	  end

	  # Find presenters based on subject
	  def by_subject(subject)
	  	return subject.presenters
	  end

	  # Find users based on availability
	  def by_time
  		presenters = []
	  	unless !@search_params[:time_part] || @search_params[:time_part].empty?
	  		x = @search_params[:time_part].split(':')
 				time = x[0].to_i * 60 + x[1].to_i

	  		# Query logic: time needs to between start and end time unless end time is < 
	  		# start time which indicates the availability extends past midnight. 
	  		Availability.where("(end_time > start_time AND start_time <= #{time} AND 
	  				end_time >= #{time}) OR (#{time} >= end_time AND #{time} >= start_time)").each do |a|
  				presenters << a.presenter
	  		end
	  		return presenters
	  	end
	  end

	  def by_day
			presenters = []
	  	unless !@search_params[:date_part] || @search_params[:date_part].empty?
	  		x = @search_params[:date_part].to_datetime.wday
  			d = ["sunday","monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
  			Availability.where("#{d[x]} = true").each do |a|
  				presenters << a.presenter
  			end
	  	end
	  	return presenters
	  end
	  	
end
