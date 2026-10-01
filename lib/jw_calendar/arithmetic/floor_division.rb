# frozen_string_literal: true

module JWCalendar
  module Arithmetic
    # Integer division rounded toward negative infinity, unlike Ruby's Integer#div
    # only in its explicit validation and documentation of the calendar use case.
    module FloorDivision
      module_function

      def div(numerator, denominator)
        unless numerator.is_a?(Integer) && denominator.is_a?(Integer) && denominator.positive?
          raise ArgumentError, "expected an Integer numerator and positive Integer denominator"
        end

        numerator.div(denominator)
      end
    end
  end
end
