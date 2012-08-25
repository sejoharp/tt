module IntervalsHelper
	def format_datetime(datetime)
		datetime.in_time_zone('Berlin').strftime('%d.%m.%Y %H:%M')
	end
	def format_time(datetime)
		datetime.in_time_zone('Berlin').strftime('%H:%M')
	end
	def format_datetime_depending_on_date(datetime)
		if datetime != nil 
			if datetime.today?
				format_time datetime
			else
				format_datetime datetime
			end
		end
	end
end
