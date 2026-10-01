# JW Calendar for Ruby

JW Calendar is a deterministic, dependency-free civil-calendar engine for Ruby. It implements proleptic Gregorian and Julian arithmetic, exact day-number conversions, ISO week dates, ordinal dates, month grids, configurable calendar reforms, lazy date ranges, and boundary reports.

**A civil date is a calendar label, not a timestamp.** `2027-01-01` does not imply midnight UTC or any other instant. JWCalendar does not consult the machine timezone, locale, or clock.

## Why this library exists

Date boundaries are easy to get subtly wrong: a date's ISO week-year can differ from its calendar year, Julian and Gregorian labels diverge, and a month grid may need dates from adjacent months. JWCalendar keeps those rules explicit and uses integer day arithmetic so the same input produces the same result on every host.

## Installation

```sh
gem install jw_calendar
```

Or add to your Gemfile:

```ruby
gem "jw_calendar"
```

## Quick Start

```ruby
require "jw_calendar"

date = JWCalendar::CivilDate.gregorian(2027, 1, 1)
date.to_s                  # => "2027-01-01"
date.weekday_name          # => "Friday"
date.iso_week.to_s         # => "2026-W53-5"
date.ordinal_day           # => 1
date.to_jdn                # => 2461407
date.add_days(1).to_s      # => "2027-01-02"
```

## Civil Dates

`JWCalendar::CivilDate` is an immutable value object with a positive year, month, day, and explicit `:gregorian` or `:julian` calendar. Dates compare by absolute day; equality and hashing also include the calendar label. `#next_day`, `#previous_day`, `#add_days`, and `#subtract_days` preserve the selected calendar.

```ruby
date = JWCalendar::CivilDate.new(2024, 2, 29, calendar: :gregorian)
date.frozen? # => true
date.ordinal_day # => 60
```

The supported year domain starts at 1 CE; year zero and BCE labels are not represented.

## Gregorian Calendar

`JWCalendar::Calendars::Gregorian` implements proleptic Gregorian leap years, month lengths, validation, ordinal day, and integer JDN conversion. “Proleptic” means the modern Gregorian rules are applied consistently to dates before their historical adoption.

## Julian Calendar

`JWCalendar::Calendars::Julian` is a distinct civil calendar with every fourth year leap. A **Julian calendar date** is not a **Julian Day Number**; the latter is an integer count of days used to map dates onto a common absolute timeline.

```ruby
gregorian = JWCalendar::CivilDate.gregorian(1582, 10, 15)
julian = JWCalendar::Conversion::CalendarConverter.convert(gregorian, to: :julian)
julian.to_s # => "1582-10-05"
```

## Julian Day Numbers

Use `JWCalendar::Conversion::JulianDayNumber` for JDN, JD, and MJD operations. JDN is an integer associated with astronomical noon. The exact JD for the start of a civil date is therefore `JDN - 1/2`; MJD is `JD - 2_400_000.5`. Fractions are represented as `Rational` when supplied as exact values.

```ruby
date = JWCalendar::CivilDate.gregorian(2000, 1, 1)
JWCalendar::Conversion::JulianDayNumber.jd(date)  # => (4903089/2)
JWCalendar::Conversion::JulianDayNumber.mjd(date) # => (51544/1)
JWCalendar::CivilDate.from_jdn(date.to_jdn)       # => same date
```

`jd(date, fraction: Rational(1, 4))` adds an explicitly supplied fraction of that civil day. This is a day fraction, not a timezone-aware time-of-day object.

## ISO Week Dates

`date.iso_week` returns an immutable `JWCalendar::ISO::WeekDate` with ISO week-year, week, and weekday (Monday=1 through Sunday=7). `#to_date` converts it back to a proleptic Gregorian `CivilDate`.

```ruby
JWCalendar::CivilDate.gregorian(2027, 1, 1).iso_week.to_s # => "2026-W53-5"
JWCalendar::ISO::WeekDate.new(2026, 53, 5).to_date.to_s   # => "2027-01-01"
```

ISO week dates follow the ISO week-year boundary rule: week 1 contains January 4, equivalently the first Thursday of the ISO week-year.

## Ordinal Dates

`JWCalendar::Conversion::OrdinalDate` represents year plus day-of-year, such as `2028-366`.

```ruby
ordinal = JWCalendar::Conversion::OrdinalDate.for(JWCalendar::CivilDate.gregorian(2028, 12, 31))
ordinal.to_s     # => "2028-366"
ordinal.to_date  # => 2028-12-31
```

## Month Grids

`JWCalendar::Grid::MonthGrid` returns immutable rows of seven semantic `Cell` values; it does not render HTML. Choose Monday or Sunday (or ISO weekday 1–7), adjacent dates, blank spillover cells, natural row count, or a fixed four-, five-, or six-week layout.

```ruby
grid = JWCalendar::Grid::MonthGrid.new(
  year: 2027, month: 1, week_start: :sunday,
  fixed_weeks: 6, include_adjacent: true
)
grid.rows.length # => 6
grid.cells.length # => 42
grid.rows.first.first.date.to_s # => "2026-12-27"
```

Each cell exposes its date (or `nil` in blank mode), `in_current_month?`, weekday, week index, and column index. `#to_h` provides a JSON-friendly structure.

## Calendar Reform

`JWCalendar::Calendars::ReformCalendar` models one explicitly configured local Julian-to-Gregorian cutover. It rejects skipped labels with `ReformGapError` and maps absolute days to the appropriate side. `ReformCalendar.papal` and `.british_empire` provide the named 1582 and 1752 profiles. These are examples of local historical rules, not a claim that one cutover applied everywhere.

```ruby
reform = JWCalendar::Calendars::ReformCalendar.papal
reform.date(1582, 10, 4).calendar # => :julian
reform.date(1582, 10, 15).calendar # => :gregorian
reform.valid_date?(1582, 10, 10) # => false
```

## Boundary Analysis

`JWCalendar::Boundary::Analyzer.year(2027)` returns a `Report` containing structured events for leap days, month/year ends, six-row months, ISO week-year rollovers, ISO week 53 dates, and Gregorian/Julian offset changes. `Analyzer.range(date_range)` analyzes an explicit lazy range. Pass `reform_calendar: JWCalendar::Calendars::ReformCalendar.papal` to include labels skipped by that profile.

```ruby
report = JWCalendar::Boundary::Analyzer.year(2024)
report.select { |event| event[:type] == :leap_day }
# => [{ type: :leap_day, date: "2024-02-29", calendar: :gregorian }]
```

## CLI

The `jwcalendar` executable is installed with the gem:

```sh
jwcalendar --help
jwcalendar --version
jwcalendar inspect 2027-01-01
jwcalendar iso-week 2027-01-01
jwcalendar jdn 2000-01-01
jwcalendar convert 2027-01-01 --from gregorian --to julian
jwcalendar grid 2027-01 --week-start monday --fixed-weeks 6
jwcalendar boundary 2027
```

Invalid input prints a concise error to standard error and exits non-zero.

## JSON Output

Add `--json` to structured commands. Output uses stable field names and exact day fractions are serialized as rational strings.

```sh
jwcalendar inspect 2027-01-01 --json
```

The JSON includes `date`, `calendar`, `weekday`, `weekday_number`, `ordinal_day`, `jdn`, `iso_week_year`, `iso_week`, and `iso_weekday`.

## Architecture

The public API is organized under `JWCalendar::CivilDate`, `Calendars`, `Conversion`, `ISO`, `Grid`, `Boundary`, and `DateRange`. Core date operations use integer arithmetic and contain no mutable global calendar state. Runtime dependencies are zero; CLI parsing and JSON use the Ruby standard library.

## Correctness Model

Gregorian and Julian dates map to integer JDNs. Weekdays are calculated from the absolute day; ISO week-years are derived using the Thursday rule. Month grids are assembled from those same date operations. Tests include deterministic round trips, broad year samples, Ruby's independent `Date` implementation for proleptic Gregorian checks, and known boundary dates. Arithmetic methods are O(1), apart from output-sized operations such as iterating a range or building a grid.

## Time Zones and Non-Goals

JWCalendar models civil dates only. It does not replace timezone databases, `TZInfo`, `ActiveSupport::TimeZone`, event scheduling, recurrence-rule engines, or a localization framework. It never assumes a civil date means midnight UTC. A caller that has an instant must choose its timezone policy before obtaining a civil date.

## Performance

Gregorian/Julian conversion, weekday, ordinal lookup, ISO week conversion, and date arithmetic are constant-time integer operations. Date ranges are lazy. The `benchmark/` directory contains reproducible Ruby `Benchmark` scripts; results depend on runtime and hardware, and no universal throughput claim is made.

## Supported Ruby Versions

JWCalendar requires Ruby 3.3 or newer. CI tests Ruby 3.3, 3.4, and 4.0.

## Development

```sh
bundle install
bundle exec rake
```

The default task runs Minitest, RuboCop, and gem packaging. Examples can be run with `ruby -Ilib examples/NAME.rb`.

## Testing

```sh
bundle exec rake test
bundle exec rubocop
gem build jw_calendar.gemspec
```

Tests cover leap rules, invalid labels, arithmetic, JDN/JD/MJD, ISO weeks, ordinals, reform gaps, grids, ranges, CLI behavior, JSON output, and deterministic round trips.

## Security

See [SECURITY.md](SECURITY.md). The gem has no runtime dependencies and declares RubyGems MFA as required for publishing.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Changes to date math should include independently checked examples and regression tests for boundaries.

## License

MIT. See [LICENSE.txt](LICENSE.txt).

## Project Website

JW Calendar's main project website is [jwcalendar.com](https://jwcalendar.com/).
