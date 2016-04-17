module CustomersHelper
	def fullname(customer)
		"#{customer.first_name} #{customer.last_name}"
	end
end
