# frozen_string_literal: true

module JWCalendar
  module Boundary
    # Finds deterministic high-risk boundaries useful for regression tests.
    class Analyzer
      class << self
        def year(year, calendar: :gregorian, reform_calendar: nil)
          return reform_year(year, reform_calendar) if reform_calendar

          unless CivilDate::CALENDARS.include?(calendar)
            raise InvalidCalendarError, "calendar must be :gregorian or :julian"
          end

          engine = calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
          engine.days_in_year(year)
          events = []
          months = (1..12).map do |month|
            days = engine.days_in_month(year, month)
            first_date = CivilDate.new(year, month, 1, calendar: calendar)
            grid = Grid::MonthGrid.new(year: year, month: month, calendar: calendar)
            events << event(:six_row_month, first_date, rows: grid.weeks) if grid.weeks == 6
            events << event(:leap_day, CivilDate.new(year, 2, 29, calendar: calendar)) if month == 2 && days == 29
            events << event(:month_end, CivilDate.new(year, month, days, calendar: calendar), month: month)
            days
          end
          events << event(:year_end, CivilDate.new(year, 12, months.last, calendar: calendar))

          first = CivilDate.new(year, 1, 1, calendar: calendar)
          last = CivilDate.new(year, 12, months.last, calendar: calendar)
          add_absolute_day_events(events, first.to_jdn, last.to_jdn, calendar: calendar)
          add_offset_change_events(events, first.to_jdn, last.to_jdn, calendar: calendar)
          Report.new(events)
        end

        def range(date_range)
          raise ArgumentError, "date_range must be a DateRange" unless date_range.is_a?(DateRange)

          events = []
          previous_offset = nil
          date_range.each do |date|
            events << event(:leap_day, date) if date.month == 2 && date.day == 29
            engine = date.calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
            events << event(:month_end, date) if date.day == engine.days_in_month(date.year, date.month)
            gregorian_date = CivilDate.from_jdn(date.to_jdn)
            iso = gregorian_date.iso_week
            if iso.week_year != gregorian_date.year
              events << event(:iso_week_year_rollover, date, iso_week_year: iso.week_year, iso_week: iso.week)
            end
            events << event(:iso_week_53, date, iso_week_year: iso.week_year, iso_week: iso.week) if iso.week == 53
            if Calendars::Gregorian.valid_date?(date.year, date.month, date.day) &&
               Calendars::Julian.valid_date?(date.year, date.month, date.day)
              offset = Calendars::Julian.to_jdn(date.year, date.month, date.day) -
                       Calendars::Gregorian.to_jdn(date.year, date.month, date.day)
              if previous_offset && offset != previous_offset
                events << event(:gregorian_julian_offset_change, date,
                                previous_offset: previous_offset, offset: offset)
              end
              previous_offset = offset
            end
          end
          Report.new(events)
        end

        private

        def add_absolute_day_events(events, first_jdn, last_jdn, calendar:)
          (first_jdn..last_jdn).each do |jdn|
            date = CivilDate.from_jdn(jdn, calendar: calendar)
            gregorian_date = CivilDate.from_jdn(jdn)
            iso = gregorian_date.iso_week
            if iso.week_year != gregorian_date.year
              events << event(:iso_week_year_rollover, date, iso_week_year: iso.week_year,
                              iso_week: iso.week)
            end
            events << event(:iso_week_53, date, iso_week_year: iso.week_year, iso_week: iso.week) if iso.week == 53
          end
        end

        def add_offset_change_events(events, first_jdn, last_jdn, calendar:)
          previous_offset = nil
          (first_jdn..last_jdn).each do |jdn|
            date = CivilDate.from_jdn(jdn, calendar: calendar)
            next unless Calendars::Gregorian.valid_date?(date.year, date.month, date.day) &&
                        Calendars::Julian.valid_date?(date.year, date.month, date.day)

            offset = Calendars::Julian.to_jdn(date.year, date.month, date.day) -
                     Calendars::Gregorian.to_jdn(date.year, date.month, date.day)
            if previous_offset && offset != previous_offset
              events << event(:gregorian_julian_offset_change, date,
                              previous_offset: previous_offset, offset: offset)
            end
            previous_offset = offset
          end
        end

        def reform_year(year, reform)
          raise ArgumentError, "reform_calendar must be a ReformCalendar" unless reform.is_a?(Calendars::ReformCalendar)
          raise ArgumentError, "year must be a positive Integer" unless year.is_a?(Integer) && year.positive?

          events = []
          reform.skipped_labels.each do |label|
            next unless label.start_with?(format("%04d-", year))

            events << { type: :reform_gap, date: label, calendar: :reform }
          end

          year_dates = []
          1.upto(12) do |month|
            dates = (1..31).map do |day|
              reform.date(year, month, day) if reform.valid_date?(year, month, day)
            end.compact
            next if dates.empty?

            year_dates.concat(dates)
            events << event(:leap_day, dates.find { |date| date.day == 29 }) if month == 2 && dates.any? { |date| date.day == 29 }
            events << event(:month_end, dates.last, month: month)
            if dates.map(&:calendar).uniq.length == 1
              grid = Grid::MonthGrid.new(year: year, month: month, calendar: dates.first.calendar)
              events << event(:six_row_month, dates.first, rows: grid.weeks) if grid.weeks == 6
            end
          end
          raise InvalidDateError, "reform calendar has no valid dates in year #{year}" if year_dates.empty?

          events << event(:year_end, year_dates.last)
          year_dates.each do |date|
            gregorian_date = CivilDate.from_jdn(date.to_jdn)
            iso = gregorian_date.iso_week
            if iso.week_year != gregorian_date.year
              events << event(:iso_week_year_rollover, date, iso_week_year: iso.week_year,
                              iso_week: iso.week)
            end
            events << event(:iso_week_53, date, iso_week_year: iso.week_year, iso_week: iso.week) if iso.week == 53
          end
          Report.new(events)
        end

        def event(type, date, extra = {})
          { type: type, date: date.to_s, calendar: date.calendar }.merge(extra)
        end
      end
    end
  end
end
