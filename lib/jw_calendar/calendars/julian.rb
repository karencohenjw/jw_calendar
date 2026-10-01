# frozen_string_literal: true

module JWCalendar
  module Calendars
    # Julian civil-calendar arithmetic. This is distinct from a Julian Day Number.
    module Julian
      module_function

      MONTH_LENGTHS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

      # Julian leap years occur every four years.
      def leap_year?(year)
        valid_year!(year)
        (year % 4).zero?
      end

      # Number of days in the requested Julian month.
      def days_in_month(year, month)
        valid_year!(year)
        valid_month!(month)
        return 29 if month == 2 && leap_year?(year)

        MONTH_LENGTHS.fetch(month - 1)
      end

      def days_in_year(year)
        leap_year?(year) ? 366 : 365
      end

      # Whether the components form a valid Julian date.
      def valid_date?(year, month, day)
        return false unless year.is_a?(Integer) && year.positive?
        return false unless month.is_a?(Integer) && month.between?(1, 12)
        return false unless day.is_a?(Integer) && day.positive?

        day <= days_in_month(year, month)
      rescue ArgumentError
        false
      end

      # Raise {InvalidDateError} unless the components form a valid date.
      def validate_date!(year, month, day)
        return true if valid_date?(year, month, day)

        raise InvalidDateError, "invalid Julian calendar date: #{[year, month, day].join('-')}"
      end

      # Convert Julian components to an integer JDN.
      def to_jdn(year, month, day)
        validate_date!(year, month, day)
        a = Arithmetic::FloorDivision.div(14 - month, 12)
        y = year + 4_800 - a
        m = month + (12 * a) - 3
        day + Arithmetic::FloorDivision.div((153 * m) + 2, 5) + (365 * y) +
          Arithmetic::FloorDivision.div(y, 4) - 32_083
      end

      # Convert an integer JDN to `[year, month, day]` Julian components.
      def from_jdn(jdn)
        raise ArgumentError, "JDN must be an Integer" unless jdn.is_a?(Integer)

        c = jdn + 32_082
        d = Arithmetic::FloorDivision.div((4 * c) + 3, 1_461)
        e = c - Arithmetic::FloorDivision.div(1_461 * d, 4)
        m = Arithmetic::FloorDivision.div((5 * e) + 2, 153)
        day = e - Arithmetic::FloorDivision.div((153 * m) + 2, 5) + 1
        month = m + 3 - (12 * Arithmetic::FloorDivision.div(m, 10))
        year = d - 4_800 + Arithmetic::FloorDivision.div(m, 10)
        raise InvalidDateError, "JDN is earlier than the supported Julian domain" unless year.positive?

        [year, month, day]
      end

      def valid_year!(year)
        return if year.is_a?(Integer) && year.positive?

        raise ArgumentError,
              "year must be a positive Integer (1 CE or later)"
      end
      private_class_method :valid_year!

      def valid_month!(month)
        return if month.is_a?(Integer) && month.between?(1, 12)

        raise ArgumentError, "month must be an Integer in 1..12"
      end
      private_class_method :valid_month!
    end
  end
end
