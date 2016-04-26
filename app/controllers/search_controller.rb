class SearchController < ApplicationController
	

	 def index 
  	@search_params = params

  	# for use in booking
  	session[:search_params] = @search_params

	 	@presenter= []
	 	
    if any_present?
    	results_added = false

	    # Search:
	    	results_added = add_presenters(by_name, results_added)
	    	results_added = add_presenters(by_subject, results_added)
	    	results_added = add_presenters(by_availability, results_added)
	    	remove_non_profiles
	  end	
	    
  end

  private

  def remove_non_profiles
  	@presenter.reject!{|d| d.nil?}
  	@presenter.reject!{|p| p.presenter_profile.nil?}
  	@presenter.reject!{|p| p.presenter_profile.bio.empty?}
  end
  # Check if anything has been entered
	  def any_present?
	    return !(params[:subject_id].blank? && params[:date_part].blank? && 
	    	params[:time_part].blank? && params[:first_name].blank?)
	  end

	  # Add found presenters to array
  	def add_presenters(x, loaded)
  		unless !x 
	  		if !loaded
	  			@presenter = x
	  			return true
	  		else
	  			@presenter &= x
	  			return true
				end		    		
			end
			return false || loaded
  	end

	  # Find presenters based on subject
	  def by_subject
	  	unless !@search_params[:subject_id] || @search_params[:subject_id].empty?
	      begin
	        subj = Subject.find(@search_params[:subject_id])
	        @search_params[:subject_name] = subj.name
	        return subj.presenters
	      rescue ActiveRecord::RecordNotFound
	      	@search_params[:subject_id] = nil
	      end
	    end
	  end

  	def by_name
  		unless !@search_params[:first_name] || @search_params[:first_name].empty?
  			x = @search_params[:first_name].upcase
  			return Presenter.where("upper(first_name) like '%#{x}%'")
  			
  		end
  	end
  	

	  # Search for presenter by availability day and times. 
	  def by_availability
  	 	presenters = []
	  	if !(query = [by_day, by_time].reject {|d| d.empty?}).empty?
	  		Availability.where("#{query*' AND '}").each do |a|
  				if a.presenter
  					presenters << a.presenter if !presenters.include? a.presenter
  				end
  			end
				return presenters
  		end
	  end

	  # Generate query string for time portion of availability search.
	  def by_time
  		str = ""
	  	unless !@search_params[:time_part] || @search_params[:time_part].empty?
	  		x = @search_params[:time_part].split(':')
 				time = x[0].to_i * 60 + x[1].to_i

	  		# Query logic: time needs to between start and end time unless end time is < 
	  		# start time which indicates the availability extends past midnight.   			
	  		str = "(end_time > start_time AND start_time <= #{time} AND end_time >= #{time})"
	  	end
  		return str
	  end

	  # Generate query string for day portion of availibility search.
	  def by_day
			str = ""
	  	unless !@search_params[:date_part] || @search_params[:date_part].empty?
	  		x = @search_params[:date_part].to_datetime.wday
  			d = ["sunday","monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
  			str = "(#{d[x]} = true)"
	  	end
	  	return str
	  end
	  	
end
