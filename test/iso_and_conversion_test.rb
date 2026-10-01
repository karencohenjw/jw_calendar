# frozen_string_literal: true

require_relative "test_helper"

class IsoAndConversionTest < Minitest::Test
  def test_iso_week_year_boundary_examples
    assert_equal "2026-W53-5", JWCalendar::CivilDate.gregorian(2027, 1, 1).iso_week.to_s
    assert_equal "2020-W53-4", JWCalendar::CivilDate.gregorian(2020, 12, 31).iso_week.to_s
    assert_equal "2020-W53-5", JWCalendar::CivilDate.gregorian(2021, 1, 1).iso_week.to_s
    assert_equal "2027-W01-1", JWCalendar::CivilDate.gregorian(2027, 1, 4).iso_week.to_s
  end

  def test_iso_week_53_years_and_invalid_weeks
    assert_equal 53, JWCalendar::ISO::WeekDate.weeks_in_year(2020)
    assert_equal 53, JWCalendar::ISO::WeekDate.weeks_in_year(2015)
    assert_equal 52, JWCalendar::ISO::WeekDate.weeks_in_year(2021)
    assert_raises(JWCalendar::InvalidISOWeekError) { JWCalendar::ISO::WeekDate.new(2021, 53, 1) }
    assert_raises(JWCalendar::InvalidISOWeekError) { JWCalendar::ISO::WeekDate.new(2027, 1, 0) }
  end

  def test_iso_conversion_round_trip_for_every_day_in_sample_years
    [1, 4, 100, 400, 1582, 1900, 2000, 2020, 2027, 2400].each do |year|
      first = JWCalendar::CivilDate.gregorian(year, 1, 1)
      days = JWCalendar::Calendars::Gregorian.days_in_year(year)
      (0...days).each do |offset|
        date = first.add_days(offset)
        assert_equal date, date.iso_week.to_date
      end
    end
  end

  def test_ordinal_date_conversion_and_validation
    date = JWCalendar::CivilDate.gregorian(2028, 12, 31)
    ordinal = JWCalendar::Conversion::OrdinalDate.for(date)
    assert_equal "2028-366", ordinal.to_s
    assert_equal date, ordinal.to_date
    assert_equal JWCalendar::CivilDate.gregorian(2027, 1, 1),
                 JWCalendar::Conversion::OrdinalDate.new(2027, 1).to_date
    julian_ordinal = JWCalendar::Conversion::OrdinalDate.new(1900, 366, calendar: :julian)
    assert_equal JWCalendar::CivilDate.julian(1900, 12, 31), julian_ordinal.to_date
    assert_raises(JWCalendar::InvalidDateError) { JWCalendar::Conversion::OrdinalDate.new(2027, 366) }
  end

  def test_jd_mjd_exact_fraction_round_trips
    date = JWCalendar::CivilDate.gregorian(2000, 1, 1)
    converter = JWCalendar::Conversion::JulianDayNumber
    assert_equal Rational(4_903_089, 2), converter.jd(date)
    assert_equal Rational(51_544, 1), converter.mjd(date)
    assert_equal [date, Rational(1, 4)], converter.from_jd(converter.jd(date, fraction: Rational(1, 4)))
    assert_equal [JWCalendar::CivilDate.gregorian(1858, 11, 17), Rational(0, 1)], converter.from_mjd(0)
    assert_equal [date, Rational(3, 4)], converter.from_mjd(converter.mjd(date, fraction: Rational(3, 4)))
    assert_raises(ArgumentError) { converter.jd(date, fraction: 1) }
  end
end
