class Availability < ActiveRecord::Base

	def get_days
		return this.days.to_s(2).rjust(7, '0')
	end

	def set_days(days)
		this.days = Integer(days, 2)
		this.save
	end
end
