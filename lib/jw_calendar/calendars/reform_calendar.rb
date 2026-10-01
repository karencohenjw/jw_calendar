# frozen_string_literal: true

module JWCalendar
  module Calendars
    # A local civil calendar switching from Julian to Gregorian labels on a
    # caller-supplied pair of consecutive absolute days.
    class ReformCalendar
      attr_reader :last_julian_date, :first_gregorian_date

      def self.papal
        new(last_julian_date: CivilDate.julian(1582, 10, 4),
            first_gregorian_date: CivilDate.gregorian(1582, 10, 15))
      end

      def self.british_empire
        new(last_julian_date: CivilDate.julian(1752, 9, 2),
            first_gregorian_date: CivilDate.gregorian(1752, 9, 14))
      end

      def initialize(last_julian_date:, first_gregorian_date:)
        @last_julian_date = coerce_date(last_julian_date, :julian)
        @first_gregorian_date = coerce_date(first_gregorian_date, :gregorian)
        unless (label(@last_julian_date) <=> label(@first_gregorian_date)) == -1
          raise ArgumentError, "last Julian label must precede first Gregorian label"
        end
        unless @first_gregorian_date.to_jdn == @last_julian_date.to_jdn + 1
          raise ArgumentError, "cutover dates must be consecutive absolute days"
        end

        freeze
      end

      def valid_date?(year, month, day)
        return false unless [year, month, day].all? { |part| part.is_a?(Integer) }

        calendar_for_label(year, month, day)
        true
      rescue InvalidDateError, ReformGapError, ArgumentError
        false
      end

      def date(year, month, day)
        calendar = calendar_for_label(year, month, day)
        CivilDate.new(year, month, day, calendar:)
      end

      def to_jdn(year, month, day)
        date(year, month, day).to_jdn
      end

      def from_jdn(jdn)
        raise ArgumentError, "JDN must be an Integer" unless jdn.is_a?(Integer)

        return CivilDate.from_jdn(jdn, calendar: :julian) if jdn <= last_julian_date.to_jdn

        CivilDate.from_jdn(jdn, calendar: :gregorian)
      end

      def skipped_labels
        start_label = last_julian_date
        end_label = first_gregorian_date
        labels = []
        cursor = start_label
        loop do
          cursor = cursor.next_day
          break if (label(cursor) <=> label(end_label)) >= 0

          labels << cursor.to_s
        end
        labels.freeze
      end

      private

      def coerce_date(value, calendar)
        return value if value.is_a?(CivilDate) && value.calendar == calendar
        return CivilDate.new(*value, calendar:) if value.is_a?(Array) && value.length == 3

        raise ArgumentError, "cutover date must be a #{calendar} CivilDate or [year, month, day]"
      end

      def calendar_for_label(year, month, day)
        unless [year, month, day].all? { |part| part.is_a?(Integer) }
          raise InvalidDateError, "year, month, and day must be integers"
        end

        tuple = [year, month, day]
        if (tuple <=> label(last_julian_date)) <= 0
          Julian.validate_date!(year, month, day)
          :julian
        elsif (tuple <=> label(first_gregorian_date)) >= 0
          Gregorian.validate_date!(year, month, day)
          :gregorian
        else
          raise ReformGapError, "#{year}-#{month}-#{day} was skipped by this calendar reform"
        end
      end

      def label(date)
        [date.year, date.month, date.day]
      end
    end
  end
end
