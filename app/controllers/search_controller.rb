class SearchController < ApplicationController
	@@first_loaded = false

	 def index 
  	@search_params = params

  	# for use in booking
  	session[:search_params] = @search_params

	 	@presenter= []
	 	
    if any_present?
	    # Search:
	    	by_subject
	    	by_name
	    	by_availability
	  end	
	    
  end

  private


  # Check if anything has been entered
	  def any_present?
	    return !(params[:subject_id].blank? && params[:date_part].blank? && 
	    	params[:time_part].blank? && params[:first_name].blank?)
	  end

	  # Add found presenters to array
  	def add_presenters(x)
  		if !@@first_loaded
  			@presenter = x
  			@@first_loaded = true
  		else
  			@presenter &= x
			end		    		
  	end

	  # Find presenters based on subject
	  def by_subject
	  	unless !@search_params[:subject_id] || @search_params[:subject_id].empty?
	      begin
	        subj = Subject.find(@search_params[:subject_id])
	        @search_params[:subject_name] = subj.name
	        add_presenters(subj.presenters)
	      rescue ActiveRecord::RecordNotFound
	      	@search_params[:subject_id] = nil
	      end
	    end
	  end

  	def by_name
  		unless !@search_params[:first_name] || @search_params[:first_name].empty?
  			x = @search_params[:first_name].upcase
  			add_presenters(Presenter.where("upper(first_name) like '%#{x}%'"))
  			
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
				add_presenters(presenters)
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
