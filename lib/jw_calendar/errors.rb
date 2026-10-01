# frozen_string_literal: true

module JWCalendar
  class Error < StandardError; end
  class InvalidDateError < Error; end
  class InvalidCalendarError < Error; end
  class InvalidISOWeekError < Error; end
  class ReformGapError < Error; end
end
