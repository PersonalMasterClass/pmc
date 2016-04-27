module SearchHelper
	def is_empty?(value)
		unless value.empty?
			return value
		end
		return ""
	end
end
