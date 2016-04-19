require 'time_tools.rb'
class Availability < ActiveRecord::Base
	belongs_to :presenter

	def get_days
		# parse int (base 10) to char array of base 2 value
		# todo big comment
		self[:days] = 0 if !self[:days]
		x = self[:days].to_s(2).rjust(7, '0').split(//)
		boolArry = []
		#convert to boolean array
		for i in 0..x.length
			boolArry[i] = (x[i] == "1")
		end
		return boolArry
	end

	# convert the days to a readable string of day names. 
	def list_days
		d = ["Mondays,", "Tuesdays,", "Wednesdays,", "Thursdays,", "Fridays,", "Saturdays,", "Sundays,"]
		x = []

		boolDays = get_days

		for i in 0..d.length
			if boolDays[i] == true
				x << d[i]
			end
		end
		x.insert(x.length - 1, "and")
		return (x*" ").chop
	end

	def start_time_string
		return to_string(self[:start_time])
	end

	def end_time_string
		return to_string(self[:end_time])
	end

		def to_string(time)
			begin
				x= (time/60).floor.to_s.rjust(2,'0') + ":" + (time % 60).floor.to_s.rjust(2,'0')	
			rescue
				x = time
			end
			return x;
		end

	# TODO error checking
	def set_days(days)
		this.days = Integer(days, 2)
		this.save
	end
end
