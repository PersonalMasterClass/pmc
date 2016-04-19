class Availability < ActiveRecord::Base
	belongs_to :presenter

	def get_days
		# parse int (base 10) to char array of base 2 value
		# todo big comment
		x = this.days.to_s(2).rjust(7, '0').split(//)
		#convert to boolean array
		for i in 0..x.length
			x[i] = (x[i] != 0)
		end
		return x
	end

	# TODO error checking
	def set_days(days)
		this.days = Integer(days, 2)
		this.save
	end
end
