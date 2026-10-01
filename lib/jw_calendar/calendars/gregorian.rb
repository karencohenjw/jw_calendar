# frozen_string_literal: true

module JWCalendar
  module Calendars
    # Proleptic Gregorian arithmetic using an integer Julian Day Number (JDN).
    # The supported civil year domain begins at 1 CE.
    module Gregorian
      module_function

      MONTH_LENGTHS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

      # Whether the Gregorian year has 366 days.
      def leap_year?(year)
        valid_year!(year)
        (year % 4).zero? && (!(year % 100).zero? || (year % 400).zero?)
      end

      # Number of days in the requested Gregorian month.
      def days_in_month(year, month)
        valid_year!(year)
        valid_month!(month)
        return 29 if month == 2 && leap_year?(year)

        MONTH_LENGTHS.fetch(month - 1)
      end

      # Number of days in a validated positive Gregorian year.
      def days_in_year(year)
        leap_year?(year) ? 366 : 365
      end

      # Whether the components form a valid Gregorian date.
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

        raise InvalidDateError, "invalid Gregorian date: #{format_components(year, month, day)}"
      end

      # Convert a Gregorian date to its integer JDN at astronomical noon.
      # Convert Gregorian components to an integer JDN.
      def to_jdn(year, month, day)
        validate_date!(year, month, day)
        a = Arithmetic::FloorDivision.div(14 - month, 12)
        y = year + 4_800 - a
        m = month + (12 * a) - 3
        day + Arithmetic::FloorDivision.div(153 * m + 2, 5) + (365 * y) +
          Arithmetic::FloorDivision.div(y, 4) - Arithmetic::FloorDivision.div(y, 100) +
          Arithmetic::FloorDivision.div(y, 400) - 32_045
      end

      # Convert an integer JDN to `[year, month, day]` Gregorian components.
      def from_jdn(jdn)
        integer_jdn!(jdn)
        a = jdn + 32_044
        b = Arithmetic::FloorDivision.div(4 * a + 3, 146_097)
        c = a - Arithmetic::FloorDivision.div(146_097 * b, 4)
        d = Arithmetic::FloorDivision.div(4 * c + 3, 1_461)
        e = c - Arithmetic::FloorDivision.div(1_461 * d, 4)
        m = Arithmetic::FloorDivision.div(5 * e + 2, 153)
        day = e - Arithmetic::FloorDivision.div(153 * m + 2, 5) + 1
        month = m + 3 - 12 * Arithmetic::FloorDivision.div(m, 10)
        year = 100 * b + d - 4_800 + Arithmetic::FloorDivision.div(m, 10)
        raise InvalidDateError, "JDN is earlier than the supported Gregorian domain" unless year.positive?
        [year, month, day]
      end

      # Return the one-based ordinal day for a valid Gregorian date.
      def day_of_year(year, month, day)
        validate_date!(year, month, day)
        prior_month_days = (1...month).inject(0) { |total, m| total + days_in_month(year, m) }
        prior_month_days + day
      end

      def valid_year!(year)
        raise ArgumentError, "year must be a positive Integer (1 CE or later)" unless year.is_a?(Integer) && year.positive?
      end
      private_class_method :valid_year!

      def valid_month!(month)
        return if month.is_a?(Integer) && month.between?(1, 12)

        raise ArgumentError, "month must be an Integer in 1..12"
      end
      private_class_method :valid_month!

      def integer_jdn!(jdn)
        return if jdn.is_a?(Integer)

        raise ArgumentError, "JDN must be an Integer"
      end
      private_class_method :integer_jdn!

      def format_components(year, month, day)
        [year, month, day].map { |part| part.to_s }.join("-")
      end
      private_class_method :format_components
    end
  end
end
