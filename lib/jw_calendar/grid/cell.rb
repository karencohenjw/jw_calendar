# frozen_string_literal: true

module JWCalendar
  module Grid
    # Immutable cell in a month grid. A nil date represents a blank spillover.
    class Cell
      attr_reader :date, :week_index, :column_index

      def initialize(date:, in_current_month:, week_index:, column_index:)
        @date = date
        @in_current_month = in_current_month
        @week_index = week_index
        @column_index = column_index
        freeze
      end

      def in_current_month?
        @in_current_month
      end

      def weekday
        date&.weekday
      end
    end
  end
end
