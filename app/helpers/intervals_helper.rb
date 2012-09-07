module IntervalsHelper
	def format_datetime(datetime)
		datetime.in_time_zone('Berlin').strftime('%d.%m.%Y %H:%M')
	end

	def format_datetime_secure(datetime)
		if not datetime.nil?
			format_datetime datetime
		end
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
		else
			''
		end
	end
end
