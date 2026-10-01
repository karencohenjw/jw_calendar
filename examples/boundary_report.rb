# frozen_string_literal: true

require "jw_calendar"
require "json"

report = JWCalendar::Boundary::Analyzer.year(2027)
puts JSON.pretty_generate(report.to_h)
