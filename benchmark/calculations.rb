# frozen_string_literal: true

require "benchmark"
require "jw_calendar"

date = JWCalendar::CivilDate.gregorian(2027, 1, 1)
jdn = date.to_jdn
iterations = Integer(ENV.fetch("N", "100000"))

Benchmark.bm(24) do |bench|
  bench.report("Gregorian to JDN") { iterations.times { JWCalendar::CivilDate.gregorian(2027, 1, 1).to_jdn } }
  bench.report("JDN to Gregorian") { iterations.times { JWCalendar::CivilDate.from_jdn(jdn) } }
  bench.report("ISO week") { iterations.times { date.iso_week } }
  bench.report("month grid") { (iterations / 100).times { JWCalendar::Grid::MonthGrid.new(year: 2027, month: 1, fixed_weeks: 6) } }
  bench.report("repeated date arithmetic") { iterations.times { date.add_days(31) } }
end
