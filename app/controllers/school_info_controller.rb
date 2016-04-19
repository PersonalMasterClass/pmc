class SchoolInfoController < ApplicationController
	def find

		render json: SchoolInfo.where("school_name LIKE ?", "%#{params[:term].titlecase}%")
	end

end
