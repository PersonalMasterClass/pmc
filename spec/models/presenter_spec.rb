require 'rails_helper'

RSpec.describe Presenter, type: :model do
    # set up
    before do
      @presenter = FactoryGirl.build(:presenter)
    end
    # verify
    it "should have a first_name" do
       expect(FactoryGirl.build(:presenter, :first_name => "")).to_not be_valid
    end

    it "should have a last_name" do
       expect(FactoryGirl.build(:presenter, :last_name => "")).to_not be_valid
    end

    it "should have a valid email" do
      expect(@presenter).to be_valid
    end

    it "should have a phone number" do
      expect(@presenter).to be_valid
    end
end

