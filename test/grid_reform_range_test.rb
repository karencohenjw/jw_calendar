# frozen_string_literal: true

require_relative "test_helper"

class GridReformRangeTest < Minitest::Test
  def test_month_grids_have_correct_dimensions_and_week_starts
    monday = JWCalendar::Grid::MonthGrid.new(year: 2027, month: 1, week_start: :monday)
    sunday = JWCalendar::Grid::MonthGrid.new(year: 2027, month: 1, week_start: :sunday)
    fixed = JWCalendar::Grid::MonthGrid.new(year: 2027, month: 1, week_start: :sunday, fixed_weeks: 6)
    assert_equal 5, monday.weeks
    assert_equal 6, sunday.weeks
    assert_equal 6, fixed.rows.length
    assert_equal 42, fixed.cells.length
    assert_equal %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday], sunday.day_names
    assert fixed.rows.all? { |row| row.length == 7 }
    assert_equal 4, JWCalendar::Grid::MonthGrid.new(year: 2021, month: 2, week_start: :monday).weeks
  end

  def test_month_grid_adjacent_and_blank_modes
    adjacent = JWCalendar::Grid::MonthGrid.new(year: 2027, month: 6, week_start: :monday)
    blank = JWCalendar::Grid::MonthGrid.new(year: 2027, month: 6, week_start: :monday, include_adjacent: false)
    assert adjacent.cells.any? { |cell| cell.date && !cell.in_current_month? }
    assert blank.cells.any? { |cell| cell.date.nil? }
    assert blank.cells.select(&:in_current_month?).all? { |cell| cell.date }
    assert_raises(ArgumentError) do
      JWCalendar::Grid::MonthGrid.new(year: 2027, month: 1, fixed_weeks: 4)
    end
  end

  def test_reform_profiles_reject_gap_and_round_trip
    reform = JWCalendar::Calendars::ReformCalendar.papal
    assert_equal %w[1582-10-05 1582-10-06 1582-10-07 1582-10-08 1582-10-09
                    1582-10-10 1582-10-11 1582-10-12 1582-10-13 1582-10-14], reform.skipped_labels
    assert_equal :julian, reform.date(1582, 10, 4).calendar
    assert_equal :gregorian, reform.date(1582, 10, 15).calendar
    refute reform.valid_date?(1582, 10, 10)
    assert_raises(JWCalendar::ReformGapError) { reform.date(1582, 10, 10) }
    assert_equal "1582-10-15", reform.from_jdn(reform.to_jdn(1582, 10, 15)).to_s
    assert_equal 11, JWCalendar::Calendars::ReformCalendar.british_empire.skipped_labels.length
  end

  def test_date_range_is_lazy_inclusive_and_calendar_consistent
    first = JWCalendar::CivilDate.gregorian(2026, 12, 30)
    last = JWCalendar::CivilDate.gregorian(2027, 1, 3)
    range = JWCalendar::DateRange.new(first, last)
    assert_equal 5, range.count
    assert_equal first, range.first
    assert_equal last, range.last
    assert_equal %w[2026-12-30 2026-12-31 2027-01-01 2027-01-02 2027-01-03], range.map(&:to_s)
    assert_equal %w[2026-12-30 2027-01-02], range.step(3).map(&:to_s)
    assert_equal %w[2027-01-02 2027-01-03], range.last(2).map(&:to_s)
    assert_equal %w[2026-12-30 2026-12-31 2027-01-01], range.weekdays.map(&:to_s)
    assert range.include?(last)
    refute range.include?(JWCalendar::CivilDate.julian(2027, 1, 1))
  end

  def test_civil_results_do_not_depend_on_timezone_environment
    date = JWCalendar::CivilDate.gregorian(2027, 1, 1)
    baseline = [date.to_s, date.to_jdn, date.weekday, date.iso_week.to_s]
    previous = ENV["TZ"]
    ["UTC", "Pacific/Apia"].each do |zone|
      ENV["TZ"] = zone
      assert_equal baseline, [date.to_s, date.to_jdn, date.weekday, date.iso_week.to_s]
    end
  ensure
    ENV["TZ"] = previous
  end

  def test_boundary_report_has_calendar_cases
    report = JWCalendar::Boundary::Analyzer.year(2027)
    assert report.any? { |event| event[:type] == :six_row_month }
    assert report.any? { |event| event[:type] == :iso_week_year_rollover }
    assert report.any? { |event| event[:type] == :iso_week_53 }
    assert JWCalendar::Boundary::Analyzer.year(2024).any? { |event| event[:type] == :leap_day }
    offset = JWCalendar::Boundary::Analyzer.year(1700).find do |event|
      event[:type] == :gregorian_julian_offset_change
    end
    assert_equal "1700-03-01", offset[:date]
    reform_report = JWCalendar::Boundary::Analyzer.year(
      1582, reform_calendar: JWCalendar::Calendars::ReformCalendar.papal
    )
    assert_equal 10, reform_report.count { |event| event[:type] == :reform_gap }
  end
end
