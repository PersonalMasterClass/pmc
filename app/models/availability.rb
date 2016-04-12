class Availability < ActiveRecord::Base

	def get_days
		return this.days.to_s(2).rjust(7, '0')
	end

	def set_days(days)
		this.days = Integer(days, 2)
		this.save
	end

	#TODO error checking for parsing
	def time_from_string(str)
		tm = str.split(':')
		h = tm[0].to_i
		m = tm[1].to_i

		return h * 60 + m
	end

	def get_start_time_string
		return get_hours(this.start_time).rjust(2,'0') + ":" + 
			get_minutes(this.start_time).rjust(2,'0')
	end

	def get_end_time_string
		return get_hours(this.end_time).rjust(2,'0') + ":" + 
			get_minutes(this.end_time).rjust(2,'0')
	end
	# time defined by minutes past midnight. 
	def get_hours(time)
		return (time/60).floor
	end

	def get_minutes(time)
		return (time % 60).floor
	end
end
