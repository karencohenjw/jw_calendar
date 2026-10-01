# frozen_string_literal: true

require_relative "test_helper"
require "date"

class CalendarArithmeticTest < Minitest::Test
  def test_gregorian_leap_year_rules
    { 1600 => true, 1700 => false, 1800 => false, 1900 => false,
      2000 => true, 2004 => true, 2100 => false, 2400 => true }.each do |year, expected|
      assert_equal expected, JWCalendar::Calendars::Gregorian.leap_year?(year), year.to_s
    end
  end

  def test_floor_division_is_explicit_for_negative_values
    assert_equal(-1, JWCalendar::Arithmetic::FloorDivision.div(-1, 7))
    assert_raises(ArgumentError) { JWCalendar::Arithmetic::FloorDivision.div(1.0, 7) }
    assert_raises(ArgumentError) { JWCalendar::Arithmetic::FloorDivision.div(1, 0) }
  end

  def test_julian_leap_year_rule
    [1600, 1700, 1800, 1900, 2000, 2100, 2400].each do |year|
      assert JWCalendar::Calendars::Julian.leap_year?(year)
    end
  end

  def test_month_lengths_and_invalid_dates
    gregorian = JWCalendar::Calendars::Gregorian
    assert_equal 29, gregorian.days_in_month(2000, 2)
    assert_equal 28, gregorian.days_in_month(1900, 2)
    refute gregorian.valid_date?(2027, 2, 29)
    refute gregorian.valid_date?(2027, 13, 1)
    assert_raises(JWCalendar::InvalidDateError) { JWCalendar::CivilDate.gregorian(2027, 4, 31) }
    assert_raises(JWCalendar::InvalidDateError) { JWCalendar::CivilDate.julian(1900, 2, 30) }
  end

  def test_known_jdn_and_historical_calendar_values
    assert_equal 2_440_588, JWCalendar::CivilDate.gregorian(1970, 1, 1).to_jdn
    assert_equal 2_451_545, JWCalendar::CivilDate.gregorian(2000, 1, 1).to_jdn
    assert_equal 2_299_160, JWCalendar::CivilDate.julian(1582, 10, 4).to_jdn
    assert_equal 2_299_161, JWCalendar::CivilDate.gregorian(1582, 10, 15).to_jdn
  end

  def test_round_trips_across_deterministic_date_sample
    (1..2400).step(37) do |year|
      (1..12).each do |month|
        day = [1, JWCalendar::Calendars::Gregorian.days_in_month(year, month)].uniq
        day.each do |value|
          date = JWCalendar::CivilDate.gregorian(year, month, value)
          assert_equal date, JWCalendar::CivilDate.from_jdn(date.to_jdn)
          assert_equal date.to_jdn, Date.new(year, month, value, Date::GREGORIAN).jd
        end
      end
    end
  end

  def test_julian_round_trips_and_calendar_conversion_preserves_absolute_day
    (100..2200).step(41) do |year|
      [1, 2, 3, 10, 12].each do |month|
        date = JWCalendar::CivilDate.julian(year, month, 1)
        assert_equal date, JWCalendar::CivilDate.from_jdn(date.to_jdn, calendar: :julian)
        converted = JWCalendar::Conversion::CalendarConverter.convert(date, to: :gregorian)
        assert_equal date.to_jdn, converted.to_jdn
        assert_equal date, JWCalendar::Conversion::CalendarConverter.convert(converted, to: :julian)
      end
    end
  end

  def test_deterministic_date_arithmetic_and_value_semantics
    date = JWCalendar::CivilDate.gregorian(2024, 2, 28)
    assert_equal JWCalendar::CivilDate.gregorian(2024, 2, 29), date.next_day
    assert_equal date, date.next_day.previous_day
    assert_equal JWCalendar::CivilDate.gregorian(2024, 3, 1), date.add_days(2)
    assert_equal 2, date.days_until(date.add_days(2))
    assert date.frozen?
    assert_equal date, date.dup
    assert_equal date.hash, date.dup.hash
    assert_equal :value, { date => :value }[date.dup]
  end

  def test_same_absolute_day_can_have_distinct_calendar_labels
    gregorian = JWCalendar::CivilDate.gregorian(1582, 10, 15)
    julian = JWCalendar::CivilDate.julian(1582, 10, 5)
    assert_equal 0, (gregorian <=> julian)
    refute_equal gregorian, julian
    assert_equal gregorian.to_jdn, julian.to_jdn
  end

  def test_year_boundary_arithmetic
    assert_equal "2028-01-01", JWCalendar::CivilDate.gregorian(2027, 12, 31).next_day.to_s
    assert_equal "2026-12-31", JWCalendar::CivilDate.gregorian(2027, 1, 1).previous_day.to_s
  end
end
