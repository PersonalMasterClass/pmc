# As availibility times and days are stored as integers, call this class for conversion.
class TimeTools

	# Converts time from Int of minutes past midnight to "hh:mm"
	def self.to_string(time)
		return (time/60).floor.to_s.rjust(2,'0') + ":" + 
			(time % 60).floor.to_s.rjust(2,'0')
	end
	
	#TODO error checking for parsing 
	# str needs to be in format "hh:mm"
	def self.from_string(str)
		tm = str.split(':')
		h = tm[0].to_i
		m = tm[1].to_i

		return h * 60 + m
	end

end