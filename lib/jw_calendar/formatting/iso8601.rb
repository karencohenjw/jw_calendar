# frozen_string_literal: true

module JWCalendar
  module Formatting
    # Strict parsing/formatting helpers for supported extended ISO civil dates.
    module ISO8601
      module_function

      def parse_date(value, calendar: :gregorian)
        CivilDate.parse(value, calendar:)
      end

      def format_date(date)
        raise ArgumentError, "date must be a CivilDate" unless date.is_a?(CivilDate)

        date.to_s
      end
    end
  end
end
