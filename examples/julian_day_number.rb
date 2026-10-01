# frozen_string_literal: true

require "jw_calendar"

date = JWCalendar::CivilDate.gregorian(2000, 1, 1)
converter = JWCalendar::Conversion::JulianDayNumber
puts "JDN: #{converter.for(date)}"
puts "JD at midnight: #{converter.jd(date)}"
puts "MJD at midnight: #{converter.mjd(date)}"
