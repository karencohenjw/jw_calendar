# frozen_string_literal: true

module JWCalendar
  module Grid
    # Deterministic structured month layout. Weeks may be natural length (4–6)
    # or fixed to six rows for print and stable UI layouts.
    class MonthGrid
      WEEKDAY_STARTS = { monday: 1, sunday: 7 }.freeze
      attr_reader :year, :month, :week_start, :fixed_weeks, :calendar

      # Build a month grid without producing any HTML or locale-dependent output.
      def initialize(year:, month:, week_start: :monday, fixed_weeks: nil,
                     include_adjacent: true, calendar: :gregorian)
        raise InvalidCalendarError, "calendar must be :gregorian or :julian" unless CivilDate::CALENDARS.include?(calendar)
        engine = calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
        engine.days_in_month(year, month)
        unless week_start.is_a?(Integer) && week_start.between?(1, 7)
          week_start = WEEKDAY_STARTS[week_start]
        end
        raise ArgumentError, "week_start must be :monday, :sunday, or ISO weekday 1..7" unless week_start
        unless fixed_weeks.nil? || [4, 5, 6].include?(fixed_weeks)
          raise ArgumentError, "fixed_weeks must be nil, 4, 5, or 6"
        end

        @year, @month, @week_start, @fixed_weeks, @calendar = year, month, week_start, fixed_weeks, calendar
        @include_adjacent = !!include_adjacent
        first = CivilDate.new(year, month, 1, calendar: calendar)
        leading = (first.weekday - week_start) % 7
        natural_weeks = ((leading + engine.days_in_month(year, month) + 6) / 7)
        weeks = fixed_weeks || natural_weeks
        if weeks < natural_weeks
          raise ArgumentError, "#{weeks} rows cannot contain all dates for #{year}-#{format('%02d', month)}"
        end
        @rows = Array.new(weeks) do |row|
          Array.new(7) do |column|
            actual = first.add_days((row * 7) + column - leading)
            in_month = actual.year == year && actual.month == month && actual.calendar == calendar
            date = in_month || @include_adjacent ? actual : nil
            Cell.new(date: date, in_current_month: in_month, week_index: row, column_index: column)
          end.freeze
        end.freeze
        freeze
      end

      # Return seven-cell rows.
      def rows
        @rows
      end

      def weeks
        rows.length
      end

      def cells
        rows.flatten.freeze
      end

      # Return column headings in display order.
      def day_names
        names = ISO::WeekDate::WEEKDAY_NAMES
        Array.new(7) { |index| names[(week_start - 1 + index) % 7] }.freeze
      end

      def to_a
        rows.map { |row| row.map { |cell| cell.date&.day } }.freeze
      end

      # Return a JSON-friendly hash of grid semantics.
      def to_h
        {
          year: year, month: month, calendar: calendar, week_start: week_start,
          fixed_weeks: fixed_weeks, weekdays: day_names,
          rows: rows.map do |row|
            row.map do |cell|
              { date: cell.date&.to_s, day: cell.date&.day,
                in_current_month: cell.in_current_month?, weekday: cell.weekday,
                week_index: cell.week_index, column_index: cell.column_index }
            end
          end
        }
      end
    end
  end
end
