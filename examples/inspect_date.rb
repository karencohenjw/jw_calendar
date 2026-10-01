# frozen_string_literal: true

require "jw_calendar"

date = JWCalendar::CivilDate.gregorian(2027, 1, 1)
puts "#{date} is #{date.weekday_name}"
puts "ordinal day: #{date.ordinal_day}"
puts "ISO week: #{date.iso_week}"
puts "JDN: #{date.to_jdn}"
