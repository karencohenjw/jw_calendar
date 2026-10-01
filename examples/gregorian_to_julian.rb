# frozen_string_literal: true

require "jw_calendar"

gregorian = JWCalendar::CivilDate.gregorian(1582, 10, 15)
julian = JWCalendar::Conversion::CalendarConverter.convert(gregorian, to: :julian)
puts "#{gregorian} Gregorian = #{julian} Julian (JDN #{julian.to_jdn})"
