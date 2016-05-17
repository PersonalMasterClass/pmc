class VitValidation
require 'open-uri'

# function to check if a given VIT number is valid, given a presenter First Name, Last Name and VIT
	def self.check_vit(presenterFirstName, presenterLastName, presenterVIT)
		page_url = "http://www.vit.vic.edu.au/search-the-register/_nocache?first_name=" + presenterFirstName + "&last_name=" + presenterLastName + "&reg_number=" + presenterVIT
	  page = Nokogiri::HTML(open(page_url))   

		# if this div does exist which indicates no result
		if !page.at_css('div#content_container_1727 p').nil?
			return false   # return false if this div and contents of the paragraph exist meaning USER does not exist
		else
			return true	   # return true if this div and contents of this paragraph do not exist meaning user DOES exist
		end
	end
end


