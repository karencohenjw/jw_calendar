# frozen_string_literal: true

require "jw_calendar"

reform = JWCalendar::Calendars::ReformCalendar.papal
puts "last Julian label: #{reform.last_julian_date}"
puts "first Gregorian label: #{reform.first_gregorian_date}"
puts "skipped labels: #{reform.skipped_labels.join(', ')}"
