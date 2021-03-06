module ApplicationHelper
	def calcuate_hours_mins_secs(duration)
		absolute_value = duration.abs
		hours_rest = absolute_value.divmod(3600)
		mins_rest = hours_rest.last.divmod(60)
		{:hours => hours_rest.first,:mins => mins_rest.first,:secs =>mins_rest.last,:negative => duration < 0}
	end
	def format_duration(duration)
		sign = duration[:negative] ? '- ' : ''
		"#{sign}#{duration[:hours]}h #{duration[:mins]}mins"
	end

	def format_safe_duration(enough_message, duration)
		if duration
			if duration <= 0
				enough_message
			else
				format_duration calcuate_hours_mins_secs duration
			end
		else
			''
		end
	end
end
