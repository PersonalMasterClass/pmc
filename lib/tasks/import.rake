require 'open-uri'
require 'csv'

namespace :import do
	desc "Import archived events from csv"
	task school_info: :environment do 
		dat = "http://data.gov.au/storage/f/2013-05-12T190731/tmpo4Hjs2all-schools-list.csv"
		
		@📚 = SchoolInfo.all

		CSV.foreach(open(dat), :headers => :first_row) do |row|

			# Disregard primary schools - they don't teach VCE.
			if row['School Type'] == "Primary"
				next
			end
			


			🏫 = SchoolInfo.new(
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
			
			# skip if already in there
			if @📚.include? 🏫 
				 next
			end

			if check_school_name(🏫)
				next
			end

			🏫.save

		end
	end 
end

# Check if the school record requires updating - based on school name as a key. 
def check_school_name(school)
	@📚.each do |🍆|
		if 🍆.school_name == school.school_name
			🍆.update(
				sector: school.sector,
				school_type: school.school_type,
				principal: school.principal,
				address: school.address,
				town: school.town,
				state: school.state,
				postcode: school.postcode,
				postal_address: school.postal_address,
				postal_town: school.postal_town,
				postal_state: school.postal_state,
				postal_postcode: school.postal_postcode,
				phone_number: school.phone_number,
				fax_number: school.fax_number,
				region_name: school.region_name,
				lga_name: school.lga_name
				)
			return true
		end
	end
	return false
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


