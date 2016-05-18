class SchoolInfoController < ApplicationController
	def find
		render json: SchoolInfo.where("school_name LIKE ?", "%#{params[:term].titlecase}%")
	end
	def show
		@school_info = SchoolInfo.find(params[:format])
		@accounts = Customer.where(school_info: params[:format])
	end
end
