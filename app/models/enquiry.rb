class Enquiry < ActiveRecord::Base
	belongs_to :presenter
	belongs_to :customer

	enum status: [:pending, :declined, :accepted]

	def self.from(current_user)
		@users = []
		if current_user.presenter?
			current_user.presenter.enquiries.each do |enquiry|
				@users << enquiry.customer
			end
		elsif current_user.customer?
			current_user.customer.enquiries.each do |enquiry|
				@users << enquiry.presenter
			end
		elsif current_user.admin?
			@users = Enquiry.select(:customer_id, :presenter_id)
		end
		return @users.uniq!
	end

	def self.conversation(current_user, id)
		@conversation = nil
		if id.present?
			if current_user.presenter?
				@conversation = Enquiry.where(presenter: current_user.presenter, customer_id: id).order(created_at: :desc)
			elsif current_user.customer?
				@conversation = Enquiry.where(customer: current_user.customer, presenter_id: id).order(created_at: :desc)
			end
		end
		return @conversation
	end
end
