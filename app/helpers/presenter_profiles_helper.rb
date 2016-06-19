module PresenterProfilesHelper
	# Display presenter's full name
	def fullname(presenter)
		"#{presenter.first_name} #{presenter.last_name}"
	end
end
