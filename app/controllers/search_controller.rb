require 'will_paginate/array'
class SearchController < ApplicationController
	before_filter :authorise_search, only: :index
	

	 def index 
  	@search_params = params
  	# for use in booking
  	session[:search_params] = @search_params
  	unless current_user.nil?
	  	if current_user.customer?
	  		session[:search_params].merge!({:creator_id => current_user.customer.id})
	  	end
	  end
	 	@presenter= []
		 	
    if any_present?
    	results_added = false

	    # Search:
	    	results_added = add_presenters(by_name, results_added)
	    	results_added = add_presenters(by_subject, results_added)
	    	results_added = add_presenters(by_availability, results_added)	    
    		if @presenter.empty?
    			@no_profiles = 0
    		else
    			@no_profiles = @presenter.count
    		end
	    	
	    	@presenter |= by_subject
	    	
	    	unless current_user.nil?
		    	if(!current_user.admin?)
		    		@presenter = remove_non_profiles(@presenter)
		    	end
	    	end 	
	  	end	
	  	pres = @presenter
	  	@presenter = WillPaginate::Collection.create(params[:page], 3, pres.length) do |pager|
 				pager.replace pres
			end

	  	# @presenter = @presenter.paginate(:page => [:params], :per_page => 3)
	  	
  end
  private

  	MAX_PROFILE_VIEWS = 3
  def authorise_search
  	if current_user.nil?
  		if cookies[:unregistered].nil?
  			cookies[:unregistered] = session.id
  			session[:profile_count] = 0
  			return
  		elsif cookies[:unregistered] == session.id
  			if session[:profile_count].to_i > MAX_PROFILE_VIEWS 
  				redirect_to registration_customers_path
				end
  			return
  		end
  	elsif current_user.presenter? 
  		redirect_to root_path
  	end
	end
  def remove_non_profiles(x)
  	unless x == nil
	  	x = x.reject{|d| d.nil?}
	  	x = x.reject{|p| p.presenter_profile.nil?}
	  	x = x.reject{|p| !p.presenter_profile.bio}
	  	x = x.reject{|p| !p.user.approved?}
	  	return x
	  end
	  	return []
  end
  # Check if anything has been entered 
	  def any_present?
	    # return !(params[:subject_id].blank? && params[:date_part].blank? && 
	    # 	params[:time_part].blank? && params[:first_name].blank?)
			return !params[:subject_id].blank?
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
			return loaded
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
  		presenters = []
  		unless !@search_params[:first_name] || @search_params[:first_name].empty?
  			x = @search_params[:first_name].upcase
  			presenters += Presenter.where("upper(first_name) like '%#{x}%'")
  			return presenters
  			
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

	  # This is here just in case we decide to searh by time later on. 
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
