class SubjectsController < ApplicationController
	def index
		@subject = Subject.all

	end

	def create
		@subject = Subject.new(subject_params)
		if @subject.save
			 redirect_to action: 'index'
		else
			render 'new'
		end
	end

	def destroy
		@subject = Subject.find(params[:id])
		@subject.destroy
		redirect_to action: 'index'
	end

	def new 
		@subject = Subject.new
	end

	def edit
		@subject = Subject.find(params[:id])
	end

	def update 
		@subject = Subject.find(params[:id])

		respond_to do |format|
			params = ActiveSupport::HashWithIndifferentAccess.new(params)
    	if @subject.update_attributes(params)
      	format.html { redirect_to(@subject, :notice => 'Subject was successfully updated.') }
      	format.json { respond_with_bip(@subject) }
    	else
      	format.html { render :action => "edit" }
      	format.json { respond_with_bip(@subject) }
    	end
  	end
	end

	

	private
		def subject_params
			params.require(:subject).permit(:name, :category)
		end
	
end

