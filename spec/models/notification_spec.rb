require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "success" do
    # set up
	  it "should send a notification to the user" do
	    @user = User.create(user_type: :customer, status: :pending,
	       										email: "arandomcustomer1@gmail.com", password: "password",
	       										password_confirmation: "password",
	       										confirmed_at: Time.now)
	    @notification = Notification.create(message: "You're account has been approved! Welcome.", 
	    																		reference: nil)
	    Notification.approve_registration(@user)

	    # verify

      expect(@user.notifications.last.message).to eq(@notification.message)
    end

	  it "should send a notification to the admin(s)" do
      @admin = User.create!(
         user_type: :admin,
         status: :approved,
         email: "rosemary@gmail.com",
         password:              "password",
         password_confirmation: "password",
         confirmed_at: Time.now)
	    @notification = Notification.create(message: "A new registration has been submitted for approval.", 
	    																		reference: nil)
	    Notification.new_registration
	    # verify
      expect(@admin.notifications.last.message).to eq(@notification.message)
    end
  end
end
