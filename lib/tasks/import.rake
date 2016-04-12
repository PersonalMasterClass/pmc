require 'open-uri'
require 'csv'

namespace :import do
	desc "Import archived events from csv"
	task school_info: :environment do 
		dat = "http://data.gov.au/storage/f/2013-05-12T190731/tmpo4Hjs2all-schools-list.csv"
		
		# 😄 = SchoolInfo.all

		CSV.foreach(open(dat), :headers => :first_row) do |row|
			if row['School Type'] == "Primary"
				next
			end
			


			SchoolInfo.create(school_name: row['School Name'])

		end
	end 
end

