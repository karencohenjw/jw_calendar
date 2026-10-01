# frozen_string_literal: true

module JWCalendar
  # Immutable civil date. It is a calendar label, not an instant or a UTC midnight.
  # Years start at 1 CE; supported calendars are proleptic Gregorian and Julian.
  class CivilDate
    include Comparable

    CALENDARS = %i[gregorian julian].freeze
    attr_reader :year, :month, :day, :calendar

    # Build a validated date label.
    # @param year [Integer] positive civil year
    # @param month [Integer] month from 1 to 12
    # @param day [Integer] valid day in the selected month
    # @param calendar [Symbol] `:gregorian` or `:julian`
    def initialize(year, month, day, calendar: :gregorian)
      raise InvalidCalendarError, "calendar must be :gregorian or :julian" unless CALENDARS.include?(calendar)

      validator = calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
      validator.validate_date!(year, month, day)
      @year = year
      @month = month
      @day = day
      @calendar = calendar
      freeze
    end

    # Create a proleptic Gregorian date.
    def self.gregorian(year, month, day)
      new(year, month, day, calendar: :gregorian)
    end

    # Create a proleptic Julian date.
    def self.julian(year, month, day)
      new(year, month, day, calendar: :julian)
    end

    # Parse an extended `YYYY-MM-DD` civil date.
    def self.parse(value, calendar: :gregorian)
      match = /\A(\d{4,})-(\d{2})-(\d{2})\z/.match(value.to_s)
      raise InvalidDateError, "expected YYYY-MM-DD, got #{value.inspect}" unless match

      new(match[1].to_i, match[2].to_i, match[3].to_i, calendar:)
    end

    # Compare by absolute day, independent of the calendar label.
    def <=>(other)
      return nil unless other.is_a?(CivilDate)

      to_jdn <=> other.to_jdn
    end

    # Equality includes the year, month, day, and calendar system.
    def ==(other)
      other.is_a?(CivilDate) && [year, month, day, calendar] == [other.year, other.month, other.day, other.calendar]
    end
    alias eql? ==

    def hash
      [year, month, day, calendar].hash
    end

    # Return this date's integer Julian Day Number.
    def to_jdn
      converter = calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
      converter.to_jdn(year, month, day)
    end

    # Return ISO weekday number, Monday=1 through Sunday=7.
    def weekday
      (to_jdn % 7) + 1 # ISO weekday: Monday=1 … Sunday=7.
    end

    def weekday_name
      ISO::WeekDate::WEEKDAY_NAMES.fetch(weekday - 1)
    end

    # Return the one-based day of year in this date's calendar.
    def ordinal_day
      first_day = calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
      to_jdn - first_day.to_jdn(year, 1, 1) + 1
    end

    # Return a new date a fixed number of civil days from this date.
    def add_days(amount)
      raise ArgumentError, "amount must be an Integer" unless amount.is_a?(Integer)

      self.class.from_jdn(to_jdn + amount, calendar:)
    end

    def subtract_days(amount)
      add_days(-amount)
    end

    def next_day
      add_days(1)
    end

    def previous_day
      add_days(-1)
    end

    def days_until(other)
      raise ArgumentError, "other must be a CivilDate" unless other.is_a?(CivilDate)

      other.to_jdn - to_jdn
    end

    # Return the ISO week date for this absolute day.
    def iso_week
      ISO::WeekDate.for(self)
    end

    def to_s
      format("%<year>04d-%<month>02d-%<day>02d", year:, month:, day:)
    end

    def to_iso8601
      to_s
    end

    def inspect
      "#<#{self.class} #{self} calendar=#{calendar}>"
    end

    # Convert an integer JDN to a date label in the selected calendar.
    def self.from_jdn(jdn, calendar: :gregorian)
      raise InvalidCalendarError, "calendar must be :gregorian or :julian" unless CALENDARS.include?(calendar)

      converter = calendar == :gregorian ? Calendars::Gregorian : Calendars::Julian
      new(*converter.from_jdn(jdn), calendar:)
    end
  end
end
