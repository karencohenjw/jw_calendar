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
        engine = calendar_engine(calendar)
        engine.days_in_month(year, month)
        week_start = normalize_week_start(week_start)
        validate_fixed_weeks!(fixed_weeks)

        @year = year
        @month = month
        @week_start = week_start
        @fixed_weeks = fixed_weeks
        @calendar = calendar
        @include_adjacent = include_adjacent
        first = CivilDate.new(year, month, 1, calendar:)
        leading, weeks = layout_dimensions(first, engine, week_start, fixed_weeks)
        @rows = build_rows(first, leading, weeks)
        freeze
      end

      # Return seven-cell rows.
      attr_reader :rows

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
          year:, month:, calendar:, week_start:,
          fixed_weeks:, weekdays: day_names,
          rows: rows.map do |row|
            row.map do |cell|
              { date: cell.date&.to_s, day: cell.date&.day,
                in_current_month: cell.in_current_month?, weekday: cell.weekday,
                week_index: cell.week_index, column_index: cell.column_index }
            end
          end
        }
      end

      private

      def calendar_engine(calendar)
        return Calendars::Gregorian if calendar == :gregorian
        return Calendars::Julian if calendar == :julian

        raise InvalidCalendarError, "calendar must be :gregorian or :julian"
      end

      def normalize_week_start(week_start)
        return week_start if week_start.is_a?(Integer) && week_start.between?(1, 7)

        normalized = WEEKDAY_STARTS[week_start]
        raise ArgumentError, "week_start must be :monday, :sunday, or ISO weekday 1..7" unless normalized

        normalized
      end

      def validate_fixed_weeks!(fixed_weeks)
        return if fixed_weeks.nil? || [4, 5, 6].include?(fixed_weeks)

        raise ArgumentError, "fixed_weeks must be nil, 4, 5, or 6"
      end

      def layout_dimensions(first, engine, week_start, fixed_weeks)
        leading = (first.weekday - week_start) % 7
        natural_weeks = (leading + engine.days_in_month(year, month) + 6) / 7
        weeks = fixed_weeks || natural_weeks
        if weeks < natural_weeks
          raise ArgumentError, "#{weeks} rows cannot contain all dates for #{year}-#{format('%02d', month)}"
        end

        [leading, weeks]
      end

      def build_rows(first, leading, weeks)
        Array.new(weeks) do |row|
          Array.new(7) do |column|
            actual = first.add_days((row * 7) + column - leading)
            in_month = actual.year == year && actual.month == month && actual.calendar == calendar
            date = in_month || @include_adjacent ? actual : nil
            Cell.new(date:, in_current_month: in_month, week_index: row, column_index: column)
          end.freeze
        end.freeze
      end
    end
  end
end
