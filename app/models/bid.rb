class Bid < ActiveRecord::Base
	belongs_to :booking
	belongs_to :presenter
end
