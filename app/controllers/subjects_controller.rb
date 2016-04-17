class SubjectsController < ApplicationController
	def index
		@subject = Subject.all
		render "subject/index"
	end

	# def create
	# 	@subject = Subject.new(subject_params)
	# 	if @subject.save
	# 		redirect_to @subject
	# 	else
	# 		render 'new'
	# 	end
	# end

	# def new 
	# 	@subject = Subject.new
	# end

	# def edit 
	# 	@subject = Subject.find(params[:id])

	# 	if @subject.update(subject_params)
	# 		redirect_to @subject
	# 	else
	# 		render 'edit'
	# end

	# private
	# 	def subject_params
	# 		params.require(:subject).permit(:name, :category)
	# 	end
	# end
end

