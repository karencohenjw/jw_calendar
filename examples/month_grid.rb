# frozen_string_literal: true

require "jw_calendar"

grid = JWCalendar::Grid::MonthGrid.new(year: 2027, month: 1, week_start: :sunday,
                                        fixed_weeks: 6, include_adjacent: true)
puts grid.day_names.map { |name| name[0, 3].rjust(4) }.join
grid.rows.each do |row|
  puts row.map { |cell| cell.date.day.to_s.rjust(4) }.join
end
