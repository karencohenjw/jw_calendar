# frozen_string_literal: true

module JWCalendar
  module Conversion
    # Converts labels between the proleptic Gregorian and Julian calendars.
    module CalendarConverter
      module_function

      # Convert a date label while preserving its absolute JDN.
      def convert(date, to:)
        raise ArgumentError, "date must be a CivilDate" unless date.is_a?(CivilDate)
        raise InvalidCalendarError, "target calendar must be :gregorian or :julian" unless CivilDate::CALENDARS.include?(to)

        CivilDate.from_jdn(date.to_jdn, calendar: to)
      end
    end
  end
end
