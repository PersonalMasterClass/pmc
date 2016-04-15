module UsersHelper
	def pending_count(presenter, customer)
		total_pending = presenter.count + customer.count
		if total_pending > 0
			"There are #{total_pending} pending registrations."
		else
			"There are no pending registrations."
		end
	end
end
