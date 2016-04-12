require 'open-uri'
require 'csv'

namespace :import do
	desc "Import archived events from csv"
	task school_info: :environment do 
		dat = "http://data.gov.au/storage/f/2013-05-12T190731/tmpo4Hjs2all-schools-list.csv"
		
		😱 = SchoolInfo.all

		CSV.foreach(open(dat), :headers => :first_row) do |row|
			if row['School Type'] == "Primary"
				next
			end
			


			😄 = SchoolInfo.new(
				school_name: row['School Name'],
				sector: row['Education Sector'],
				school_type: row['School Type'],
				principal: row['Principal'],
				address: address_string(row['Address 1'], row['Address 2'])	,
				town: row['Address Town'],
				state: row['Address State'],
				postcode: row['Address Post Code'],
				postal_address: address_string(row['Postal Address 1'], row['Postal Address 2']),
				postal_town: row['Postal Town'],
				postal_state: row['Postal State'],
				postal_postcode: row['Postal Post Code'],
				phone_number: row['Phone Number'],
				fax_number: row['Fax Number'],
				region_name: row ['Region Name'],
				lga_name: row['LGA Name']

				)

			😄.save

		end
	end 
end

# Convert two address lines into one.
def address_string (string1, string2)
	str = ""
	str += string1

	if string2 != nil
		str += (" " + string2)
	end

	return str
end


