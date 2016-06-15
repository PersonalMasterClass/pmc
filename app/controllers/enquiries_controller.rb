class EnquiriesController < ApplicationController
	before_filter :get_enquiry, :only => [:accept, :decline]

	# Enquiry index for schools and presenters
	def index
		@users = Enquiry.from(current_user)
		@conversation = Enquiry.conversation(current_user, params[:id])
	end

	# Display a particular enquiry
	def show
		@enquiry = Enquiry.find(params[:id])
	end

	def new
		@enquiry = Enquiry.new
	end

	# Creates an enquiry from the perspective of a school or presenter
	# Facilitates back and forth enquirying
	def create
		@enquiry = Enquiry.new(enquiry_params)
		flash[:success] = "Success! You've sent you're enquiry"
		if current_user.customer?
			@presenter = Presenter.find(params[:enquiry][:recipient_id])
			@enquiry.customer = current_user.customer
			@enquiry.from = :customer
			@enquiry.presenter = @presenter
			@enquiry.save
			@message = "New enquiry from #{current_user.customer.school_info.school_name}."
			Notification.send_message(@presenter.user, @message, enquiry_path(@enquiry), :new_enquiry)
			Notification.notify_admin(@message, enquiry_path(@enquiry), :new_enquiry)
			redirect_to customers_path
		elsif current_user.presenter?
			@customer = Customer.find(params[:enquiry][:recipient_id])
			@enquiry.presenter = current_user.presenter
			@enquiry.from = :presenter
			@enquiry.customer = @customer
			@enquiry.status = :counteroffer
			@enquiry.save
			@message = "#{current_user.presenter.get_private_full_name(@customer.user)} has responded with a counter offer."
			Notification.send_message(@customer.user, @message, enquiry_path(@enquiry), :counter_enquiry)
			Notification.notify_admin(@message, enquiry_path(@enquiry), :counter_enquiry)
			redirect_to customers_path
		end
	end

	# Enquiry is accepted, state of booking is changed, recipient and admin(s) are notified
	def accept
		@enquiry.status = :accepted
		@enquiry.save
		if current_user.customer?
			@message = "#{@enquiry.presenter.get_private_full_name(current_user)} has accepted the request, please confirm the booking."
		elsif current_user.presenter?
			@message = "#{@enquiry.customer.school_info.school_name} has accepted the request, please confirm the booking."
		end
		Notification.send_message(@enquiry.customer.user, @message, enquiry_path(@enquiry), :accept_enquiry)
		Notification.notify_admin(@message, enquiry_path(@enquiry), :accept_enquiry)
		flash[:success] = "Enquiry sent and accepted."
		redirect_to root_path
	end

	# Only available if an enquiry's status is :accepted
	# Change enquiry's status to :booked and redirected to booking controller
	def booked
		@enquiry = Enquiry.find(params[:enquiry_id])
		@enquiry.status = :booked
		@enquiry.save
		redirect_to new_booking_path(rate: @enquiry.rate, date: @enquiry.date.strftime("%d/%m/%Y"),
										 time: @enquiry.time.strftime("%H:%M %p"), presenter_id: @enquiry.presenter.id)
	end

	# Decline an enquiry
	def decline
		@enquiry.status = :declined
		@enquiry.save
		if current_user.customer?
			@message = "#{@enquiry.presenter.get_private_full_name(current_user)} has declined your enquiry."
		elsif current_user.presenter?
			@message = "#{@enquiry.customer.school_info.school_name} has declined your enquiry."
		end
		Notification.send_message(@enquiry.customer.user, @message, enquiry_path(@enquiry), :declined_enquiry)
		Notification.notify_admin(@message, enquiry_path(@enquiry), :declined_enquiry)
		redirect_to root_path
	end

  private
    def enquiry_params
      params.require(:enquiry).permit(:rate, :date, :time, :duration)
    end

    def get_enquiry
    	@enquiry = Enquiry.find(params[:enquiry_id])
    end
end
