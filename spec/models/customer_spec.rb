require 'rails_helper'

RSpec.describe Customer, type: :model do
    # set up
    before do
      @customer = FactoryGirl.build(:customer)
    end
    # verify
    it "should have a first_name" do
       expect(FactoryGirl.build(:customer, :first_name => "")).to_not be_valid
    end

    it "should have a last_name" do
       expect(FactoryGirl.build(:customer, :last_name => "")).to_not be_valid
    end

    it "should have a valid email" do
      expect(@customer).to be_valid
    end

    it "should have a phone number" do
      expect(@customer).to be_valid
    end
    it "should have a department" do
      expect(FactoryGirl.build(:customer, :department => "")).to_not be_valid
    end
    it "should have a phone number" do
      expect(@customer).to be_valid
    end
end

