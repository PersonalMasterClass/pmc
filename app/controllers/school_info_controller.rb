class SchoolInfoController < ApplicationController
	# Find all School infos based on search term
	def find
		render json: SchoolInfo.where("school_name LIKE ?", "%#{params[:term].titlecase}%")
	end

	# Display School info
	def show
		@school_info = SchoolInfo.find(params[:id])
		@accounts = Customer.where(school_info: params[:id])
	end
end
