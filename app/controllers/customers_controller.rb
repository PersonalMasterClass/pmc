class CustomersController < ApplicationController
	def index
	end

	def show
		@customer = Customer.find(params[:id])
		@user = @customer.get_user
	end
end
