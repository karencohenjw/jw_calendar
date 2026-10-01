# frozen_string_literal: true

require "jw_calendar"

[JWCalendar::CivilDate.gregorian(2026, 12, 31),
 JWCalendar::CivilDate.gregorian(2027, 1, 1),
 JWCalendar::CivilDate.gregorian(2027, 1, 4)].each do |date|
  puts "#{date} => #{date.iso_week}"
end
