# frozen_string_literal: true

module JWCalendar
  module Conversion
    # Integer JDN and exact JD/MJD conversions. A civil date starts at midnight;
    # its JDN is the integer labelled at the following astronomical noon.
    module JulianDayNumber
      module_function

      HALF = Rational(1, 2)
      MJD_OFFSET = Rational(2_400_001, 1)

      # Return the date's integer JDN.
      def for(date)
        date.to_jdn
      end

      # Convert an integer JDN into a civil date.
      def to_date(jdn, calendar: :gregorian)
        CivilDate.from_jdn(jdn, calendar: calendar)
      end

      # Return exact Julian Date for an explicitly supplied fraction of a day.
      # Return JD at midnight plus an optional exact fraction of a day.
      def jd(date, fraction: 0)
        fraction = rational_fraction!(fraction)
        raise ArgumentError, "fraction must be in 0...1" unless fraction >= 0 && fraction < 1

        Rational(date.to_jdn, 1) - HALF + fraction
      end

      # Convert exact JD to [civil_date, fraction_of_day] at midnight boundaries.
      # Split a JD into a civil date and exact fraction since midnight.
      def from_jd(value, calendar: :gregorian)
        jd_value = rational_number!(value)
        shifted = jd_value + HALF
        jdn = shifted.floor
        [to_date(jdn, calendar: calendar), shifted - jdn]
      end

      # Return MJD at midnight plus an optional exact fraction of a day.
      def mjd(date, fraction: 0)
        fraction = rational_fraction!(fraction)
        raise ArgumentError, "fraction must be in 0...1" unless fraction >= 0 && fraction < 1

        Rational(date.to_jdn, 1) - MJD_OFFSET + fraction
      end

      # Split an MJD into a civil date and exact fraction since midnight.
      def from_mjd(value, calendar: :gregorian)
        mjd_value = rational_number!(value)
        day_offset = mjd_value.floor
        fraction = mjd_value - day_offset
        # MJD 0 is Gregorian 1858-11-17 at midnight (JDN 2,400,001).
        [to_date(day_offset + 2_400_001, calendar: calendar), fraction]
      end

      def rational_fraction!(value)
        raise ArgumentError, "fraction must be Numeric" unless value.is_a?(Numeric)

        value.to_r
      end
      private_class_method :rational_fraction!

      def rational_number!(value)
        raise ArgumentError, "Julian date value must be Numeric" unless value.is_a?(Numeric)

        value.to_r
      rescue RangeError
        raise ArgumentError, "Julian date value must be finite"
      end
      private_class_method :rational_number!
    end
  end
end
