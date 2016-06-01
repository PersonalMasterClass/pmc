class EnquiriesController < ApplicationController
	before_filter :get_enquiry, :only => [:accept, :decline]
	def index
		@users = Enquiry.from(current_user)
		@conversation = Enquiry.conversation(current_user, params[:id])
	end

	def show
		@enquiry = Enquiry.find(params[:id])
	end

	def new
		@enquiry = Enquiry.new
	end

	def create
		@enquiry = Enquiry.new(enquiry_params)
		flash[:success] = "Success! You've sent you're enquiry"
		if current_user.customer?
			@presenter = Presenter.find(params[:enquiry][:recipient_id])
			@enquiry.customer = current_user.customer
			@enquiry.presenter = @presenter
			@enquiry.save
			@message = "New enquiry from #{current_user.customer.school_info.school_name}."
			Notification.send_message(@presenter.user, @message, enquiry_path(@enquiry))
			redirect_to customers_path
		elsif current_user.presenter?
			@customer = Customer.find(params[:enquiry][:recipient_id])
			@enquiry.presenter = current_user.presenter
			@enquiry.customer = @customer
			@enquiry.save
			binding.pry
			@message = "#{current_user.presenter.get_private_full_name(@customer.user)} has responded with a counter offer."
			Notification.send_message(@customer.user, @message, enquiry_path(@enquiry))
			redirect_to customers_path
		end
	end

	def accept
		@enquiry.status = :accepted
		@enquiry.save
		@message = "#{current_user.presenter.get_private_full_name(@enquiry.customer.user)} has accepted the request, please confirm the booking."
		Notification.send_message(@enquiry.customer.user, @message, enquiry_path(@enquiry))
		redirect_to root_path
	end

	def decline
		@enquiry.status = :declined
		@enquiry.save
		@message = "#{current_user.presenter.get_private_full_name(@enquiry.customer.user)} has declined your enquiry."
		Notification.send_message(@enquiry.customer.user, @message, enquiry_path(@enquiry))
		redirect_to root_path
	end

  private
    def enquiry_params
      params.require(:enquiry).permit(:rate, :date, :time)
    end

    def get_enquiry
    	@enquiry = Enquiry.find(params[:enquiry_id])
    end
end
