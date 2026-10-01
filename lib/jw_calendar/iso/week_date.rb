# frozen_string_literal: true

module JWCalendar
  module ISO
    # ISO week date value with Monday=1 through Sunday=7.
    class WeekDate
      WEEKDAY_NAMES = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze
      attr_reader :week_year, :week, :weekday

      # Create a valid ISO week-year, week, and weekday tuple.
      def initialize(week_year, week, weekday)
        unless week_year.is_a?(Integer) && week_year.positive?
          raise InvalidISOWeekError, "ISO week-year must be a positive Integer"
        end
        unless weekday.is_a?(Integer) && weekday.between?(1, 7)
          raise InvalidISOWeekError, "ISO weekday must be in 1..7"
        end
        weeks = self.class.weeks_in_year(week_year)
        unless week.is_a?(Integer) && week.between?(1, weeks)
          raise InvalidISOWeekError, "ISO week must be in 1..#{weeks} for #{week_year}"
        end

        @week_year = week_year
        @week = week
        @weekday = weekday
        freeze
      end

      # Compute the ISO week date for an absolute civil date.
      def self.for(date)
        raise ArgumentError, "date must be a CivilDate" unless date.is_a?(CivilDate)

        weekday = date.weekday
        # The Thursday determines the ISO week-year, even for Julian labels.
        thursday = CivilDate.from_jdn(date.to_jdn + 4 - weekday)
        week_year = thursday.year
        jan4 = Calendars::Gregorian.to_jdn(week_year, 1, 4)
        week1_monday = jan4 - (jan4 % 7)
        week = Arithmetic::FloorDivision.div(date.to_jdn - week1_monday, 7) + 1
        new(week_year, week, weekday)
      end

      # Return 52 or 53 according to the ISO week-year rule.
      def self.weeks_in_year(year)
        raise InvalidISOWeekError, "ISO week-year must be a positive Integer" unless year.is_a?(Integer) && year.positive?

        jan1_weekday = (Calendars::Gregorian.to_jdn(year, 1, 1) % 7) + 1
        return 53 if jan1_weekday == 4 || (jan1_weekday == 3 && Calendars::Gregorian.leap_year?(year))

        52
      end

      # Convert the ISO tuple to a proleptic Gregorian CivilDate.
      def to_date
        jan4 = Calendars::Gregorian.to_jdn(week_year, 1, 4)
        week1_monday = jan4 - (jan4 % 7)
        CivilDate.from_jdn(week1_monday + ((week - 1) * 7) + weekday - 1)
      end

      def to_s
        format("%04d-W%02d-%d", week_year, week, weekday)
      end

      def weekday_name
        WEEKDAY_NAMES.fetch(weekday - 1)
      end

      def ==(other)
        other.is_a?(WeekDate) && [week_year, week, weekday] == [other.week_year, other.week, other.weekday]
      end
      alias eql? ==

      def hash
        [week_year, week, weekday].hash
      end
    end
  end
end
