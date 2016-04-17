class SubjectController < ApplicationController
	def index
		@subject = Subject.all
	end

	def create
		@subject = Subject.new(subject_params)
	end

	def new 
		@subject = Subject.new
	end
	
end
