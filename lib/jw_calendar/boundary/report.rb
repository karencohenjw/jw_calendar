# frozen_string_literal: true

module JWCalendar
  module Boundary
    # Immutable collection of machine-readable boundary events.
    class Report
      include Enumerable
      attr_reader :events

      def initialize(events)
        @events = events.map(&:freeze).freeze
        freeze
      end

      def each(&)
        events.each(&)
      end

      def to_a
        events
      end

      def to_h
        { events: }
      end
    end
  end
end
