# frozen_string_literal: true

module JWCalendar
  module Boundary
    # Immutable collection of machine-readable boundary events.
    class Report
      include Enumerable
      attr_reader :events

      def initialize(events)
        @events = events.map { |event| event.freeze }.freeze
        freeze
      end

      def each(&block)
        events.each(&block)
      end

      def to_a
        events
      end

      def to_h
        { events: events }
      end

    end
  end
end
