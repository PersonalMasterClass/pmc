class SchoolInfoController < ApplicationController
	def find
		render json: SchoolInfo.where("school_name LIKE ?", "%#{params[:term].titlecase}%")
	end
	def show
		@school_info = SchoolInfo.find(params[:id])
		@accounts = Customer.where(school_info: params[:id])
	end
end
