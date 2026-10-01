# frozen_string_literal: true

module JWCalendar
  # Lazy inclusive range of dates from one calendar system.
  class DateRange
    include Enumerable

    attr_reader :start_date, :end_date

    # Create an inclusive range with matching calendar systems.
    def initialize(start_date, end_date)
      unless start_date.is_a?(CivilDate) && end_date.is_a?(CivilDate)
        raise ArgumentError, "range endpoints must be CivilDate objects"
      end
      unless start_date.calendar == end_date.calendar
        raise InvalidCalendarError, "range endpoints must use the same calendar"
      end
      raise ArgumentError, "start_date must not follow end_date" if start_date > end_date

      @start_date = start_date
      @end_date = end_date
      freeze
    end

    # Yield each date without first materializing the range.
    def each
      return enum_for(:each) unless block_given?

      offset = 0
      while offset <= count - 1
        yield start_date.add_days(offset)
        offset += 1
      end
      self
    end

    # Number of dates in the inclusive interval.
    def count
      start_date.days_until(end_date) + 1
    end
    alias size count

    def include?(date)
      date.is_a?(CivilDate) && date.calendar == start_date.calendar &&
        date.to_jdn >= start_date.to_jdn && date.to_jdn <= end_date.to_jdn
    end

    def first(number = nil)
      return start_date if number.nil?
      raise ArgumentError, "number must be a non-negative Integer" unless number.is_a?(Integer) && number >= 0

      take(number)
    end

    def last(number = nil)
      return end_date if number.nil?
      raise ArgumentError, "number must be a non-negative Integer" unless number.is_a?(Integer) && number >= 0
      return [] if number.zero?

      first_index = [count - number, 0].max
      (first_index...count).map { |offset| start_date.add_days(offset) }
    end

    def step(days = 1)
      raise ArgumentError, "step must be a positive Integer" unless days.is_a?(Integer) && days.positive?
      return enum_for(:step, days) unless block_given?

      offset = 0
      while offset < count
        yield start_date.add_days(offset)
        offset += days
      end
      self
    end

    def weekdays
      return enum_for(:weekdays) unless block_given?

      each { |date| yield date unless [6, 7].include?(date.weekday) }
      self
    end
  end
end
