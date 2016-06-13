require 'rails_helper'

RSpec.describe Booking, type: :model do
	describe 'on create' do
	  # set up
	  before do
	    @booking = FactoryGirl.build(:booking)
	  end

		# verify
    it "is valid" do
       expect(@booking).to be_valid
    end
	end

	describe 'with help required' do
	  # set up
	  before do
	    @booking = Booking.first
	    @booking.help_required = true
	    @booking.save
	  end

		it "returns all bookings that require help" do
			# exercise
			help_required_booking = Booking.help_required

			# verify
			expect(help_required_booking).to include(@booking) 
		end
	end
end
