# frozen_string_literal: true

module JWCalendar
  module Conversion
    # Immutable year/day-of-year value, using the selected civil calendar.
    class OrdinalDate
      attr_reader :year, :day, :calendar

      # Create a validated year and ordinal day.
      def initialize(year, day, calendar: :gregorian)
        unless CivilDate::CALENDARS.include?(calendar)
          raise InvalidCalendarError, "calendar must be :gregorian or :julian"
        end

        engine = calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
        engine.days_in_year(year)
        unless day.is_a?(Integer) && day.between?(1, engine.days_in_year(year))
          raise InvalidDateError, "ordinal day must be in 1..#{engine.days_in_year(year)} for #{year}"
        end

        @year = year
        @day = day
        @calendar = calendar
        freeze
      end

      # Convert a CivilDate to its ordinal form.
      def self.for(date)
        new(date.year, date.ordinal_day, calendar: date.calendar)
      end

      # Convert the ordinal value to its calendar date.
      def to_date
        jan1 = CivilDate.new(year, 1, 1, calendar:)
        jan1.add_days(day - 1)
      end

      def to_s
        format("%<year>04d-%<day>03d", year:, day:)
      end

      def ==(other)
        other.is_a?(OrdinalDate) && [year, day, calendar] == [other.year, other.day, other.calendar]
      end
      alias eql? ==

      def hash
        [year, day, calendar].hash
      end
    end
  end
end
