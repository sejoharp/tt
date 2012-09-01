module IntervalsHelper
	def format_datetime(datetime)
		datetime.in_time_zone('Berlin').strftime('%d.%m.%Y %H:%M')
	end
	def format_time(datetime)
		datetime.in_time_zone('Berlin').strftime('%H:%M')
	end
	def format_datetime_depending_on_date(datetime)
		if not datetime.nil?
			if datetime.today?
				format_time datetime
			else
				format_datetime datetime
			end
		end
	end
	def calcuate_hours_mins_secs(duration)
		absolute_value = duration.abs
		hours_rest = absolute_value.divmod(3600)
		mins_rest = hours_rest.last.divmod(60)
		{:hours => hours_rest.first,:mins => mins_rest.first,:secs =>mins_rest.last,:negative => duration < 0}
	end
	def format_duration(hours_mins_secs)
		sign = hours_mins_secs[:negative] ? '- ' : ''
		"#{sign}#{hours_mins_secs[:hours]}h #{hours_mins_secs[:mins]}mins #{hours_mins_secs[:secs]}secs"
	end
end
