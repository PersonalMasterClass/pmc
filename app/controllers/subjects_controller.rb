class SubjectsController < ApplicationController
before_filter :find_subjects, :only => [:edit, :update, :destroy]
before_filter :admin_logged_in, :only => [:update, :destroy, :edit]
before_filter :customer_logged_in, :only => [:subscribe, :subscriptions]

	def index
		if current_user.user_type == "admin"
			@subject = Subject.all
		else
			@subject = Subject.by_presenter(current_user.presenter)
		end
	end

	def view_presenters
		@subject = Subject.find(params[:subject_id])
		@presenters = @subject.presenters
	end

	def create
		@subject = Subject.new(subject_params)
		if @subject.save
			 redirect_to action: 'index'
		else
			render 'new'
		end
	end

	def find
		render json: Subject.where("name LIKE ?","%#{params[:term].titlecase}%")
	end

	def destroy
		@subject.destroy
		redirect_to action: 'index'
	end

	def new 
		@subject = Subject.new
	end

	def edit
		
	end

	def update 
		respond_to do |format|
			
    	if @subject.update(subject_params)
    		# flash[:success] ="Subject was successfully updated."
      	# format.html { redirect_to(@subject, :notice => '') }
      	format.json { respond_with_bip(@subject) }
      	
    	else
      	format.html { render :action => "edit" }
      	format.json { respond_with_bip(@subject) }
    	end
  	end
	end

	def subscriptions
		@subscriptions = current_user.customer.subjects
	end
	
	def subscribe
		@subject = Subject.find(params[:id])
		@customer = current_user.customer
		customer.subjects << @subject
		flash[:success] = "You have subscribed to #{@subject.name}."
		redirect_to root_url
	end

	private
		def subject_params
			params.require(:subject).permit(:name, :note)
		end

		def find_subjects
			@subject = Subject.find(params[:id])
		end

		def admin_logged_in
      if current_user.nil? || !current_user.admin?
        # TODO remove this for production
        flash[:danger] = "Admin can only edit subjects."
        redirect_to root_url
      end
    end

		def customer_logged_in
      if current_user.nil? || !current_user.customer?
        flash[:danger] = "Unauthorised access."
        redirect_to root_url
      end
    end
	
end

