module SearchHelper

	# check if search vaue is empty
	def is_empty?(value)
		unless value.nil?
			return value
		end
		return ""
	end
end
