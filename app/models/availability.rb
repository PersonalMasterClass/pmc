require 'time_tools.rb'
class Availability < ActiveRecord::Base
	belongs_to :presenter

	# convert each day attribute to a single bool array
	def get_days
		bool_array = []

		bool_array << self[:monday]
		bool_array << self[:tuesday]
		bool_array << self[:wednesday]
		bool_array << self[:thursday]
		bool_array << self[:friday]
		bool_array << self[:saturday]
		bool_array << self[:sunday]

		return bool_array
	end

	# get bookings for current user
	def self.for_presenter(presenter)
		return Availability.where(presenter: presenter).order('availabilities.start_time ASC')
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
	def times_string
		return start_time_string + " - " + end_time_string
	end
	def start_time_string
		return to_string(self[:start_time])
	end

	def end_time_string
		plus = ""
		if end_time < start_time
			plus = "+"
		end
		return to_string(self[:end_time]) + plus
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
