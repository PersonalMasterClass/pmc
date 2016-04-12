require 'rails_helper'

RSpec.describe User, type: :model do
  describe "registration" do
    # set up
    before do
      @user = FactoryGirl.create(:user)
      @user.customer = FactoryGirl.create(:customer)
    end
    # verify
    it "should have a valid factory" do
       expect(@user).to be_valid
    end

    it "should have a password length >= 8" do
      user = FactoryGirl.build(:user, :password => "pass", :password_confirmation => "word")
      expect(user).to_not be_valid
    end
    it "should have an email" do
      user = FactoryGirl.build(:user, :email => "")
      expect(user).to_not be_valid
    end
  end

  describe "customer registration" do
    # set up
    before do
      @user = FactoryGirl.create(:user)
      @user.customer = FactoryGirl.create(:customer)
      @user.user_type = :customer
      @user.status = :pending
    end
    # verify
    it "should save a user record" do
      expect(@user).to be_valid
    end
    it "should save a customer record" do
      expect(@user.customer).to be_valid
    end
    it "should be of type customer" do
      expect(@user.user_type).to eq "customer"
    end
    it "should be in a pending status" do
      expect(@user.status).to eq "pending"
    end
  end
  
  describe "presenter registration" do
    # set up
    before do
      @user = FactoryGirl.create(:user)
      @user.presenter = FactoryGirl.create(:presenter)
      @user.user_type = :presenter
      @user.status = :pending
    end
    # exercise 
    # verify
    it "should save a user record" do
      expect(@user).to be_valid
    end
    it "should save a presenter record" do
      expect(@user.presenter).to be_valid
    end
    it "should be of type customer" do
      expect(@user.user_type).to eq "presenter"
    end
    it "should be in a pending status" do
      expect(@user.status).to eq "pending"
    end
  end
end

