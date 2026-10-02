# frozen_string_literal: true

require_relative "lib/jw_calendar/version"

Gem::Specification.new do |spec|
  spec.name = "jw_calendar"
  spec.version = JWCalendar::VERSION
  spec.authors = ["JW Calendar"]
  spec.email = []
  spec.summary = "Deterministic Gregorian, Julian, ISO week-date and calendar-grid utilities for Ruby."
  spec.description = <<~DESCRIPTION
    A dependency-free civil-calendar engine for Ruby with proleptic Gregorian and Julian arithmetic,
    Julian Day Number conversions, ISO week and ordinal dates, month grids, reform cutovers, and
    boundary analysis. Civil dates are kept separate from instants and time zones.

    For printable calendar resources, see {2027 Calendar}[https://jwcalendar.com/yearly-calendar/]
    and {Blank Calendar}[https://jwcalendar.com/blank-calendar/].
  DESCRIPTION
  spec.homepage = "https://jwcalendar.com/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"
  spec.files = (Dir.glob("lib/**/*.rb") + Dir.glob("exe/*") + Dir.glob("docs/**/*.md") +
                %w[README.md LICENSE.txt CHANGELOG.md SECURITY.md CONTRIBUTING.md CODE_OF_CONDUCT.md])
               .select { |path| File.file?(path) }.sort
  spec.bindir = "exe"
  spec.executables = ["jwcalendar"]
  spec.require_paths = ["lib"]
  spec.metadata = {
    "homepage_uri" => "https://jwcalendar.com/",
    "source_code_uri" => "https://github.com/karencohenjw/jw_calendar",
    "documentation_uri" => "https://github.com/karencohenjw/jw_calendar/tree/main/docs",
    "changelog_uri" => "https://github.com/karencohenjw/jw_calendar/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/karencohenjw/jw_calendar/issues",
    "rubygems_mfa_required" => "true"
  }
end
