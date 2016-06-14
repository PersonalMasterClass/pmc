require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "that is successful" do
    # set up
	  it "should send a notification to the user" do
	    @user = User.create(user_type: :customer, status: :pending,
	       										email: "arandomcustomer1@gmail.com", password: "password",
	       										password_confirmation: "password",
	       										confirmed_at: Time.now)
	    @notification = Notification.create(message: "You're account has been approved! Welcome.", 
	    																		reference: nil)
	    Notification.send_message(@user, "You're account has been approved! Welcome.", "/", :system)

	    # verify

      expect(@user.notifications.last.message).to eq(@notification.message)
    end

	  it "should send a notification to the admin(s)" do
      @admin = User.find_by(user_type: 2)
			@message = "A new registration has been submitted for approval."
	    Notification.notify_admin(@message, "/", :system)
	    # verify
      expect(@admin.notifications.last.message).to eq(@message)
    end
  end
  describe "for a booking to applicable users" do
  	context "when the user is a customer" do
  		it "should send a notification to all applicants" do
		  	# set up
		  	@count = 0
		  	@booking = Booking.last
		  	@customers = Customer.joins(:subjects).where(subjects: {name: @booking.subject.name})

		  	# exercise
		  	Notification.notify_applicable_users(@booking.creator, @booking, "customer", "/", "This is a booking message", :booking)
		  	@customers.each do |customer|
		  		if customer.user.notifications.last.message ==  "This is a booking message"
		  			@count += 1
		  		end
		  	end

		  	# verify
		  	expect(@customers.count).to eq(@count)
	  	end
	  end
 		context "when the user is a presenter" do
  		it "should send a notification to all applicants" do
		  	# set up
		  	@count = 0
		  	@booking = Booking.last
		  	@presenters = Presenter.joins(:subjects).where(subjects: {name: @booking.subject.name})

		  	# exercise
		  	Notification.notify_applicable_users(@booking.creator, @booking, "presenter", "/", "This is a booking message", :booking)
		  	@presenters.each do |presenter|
		  		if presenter.user.notifications.last.message ==  "This is a booking message"
		  			@count += 1
		  		end
		  	end
		  	# verify
		  	expect(@presenters.count).to eq(@count)
	  	end
	  end
  end
end
