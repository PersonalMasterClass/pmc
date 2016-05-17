module SearchHelper
	def is_empty?(value)
		unless value.nil?
			return value
		end
		return ""
	end
end
