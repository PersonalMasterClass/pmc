module PresenterProfilesHelper
	def fullname(presenter)
		"#{presenter.first_name} #{presenter.last_name}"
	end
end
