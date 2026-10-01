# Contributing

## Development setup

Use Ruby 3.3 or newer, then run:

```sh
bundle install
bundle exec rake
```

Run an example with `ruby -Ilib examples/inspect_date.rb`.

## Calendar correctness

Calendar code needs explicit, independently checked expected values. Keep civil labels separate from instants and timezones. When changing an algorithm, add boundary regressions (especially month/year transitions, ISO week-years, leap rules, and calendar cutovers), plus deterministic round-trip or invariant coverage. Use Ruby's `Date` only as an independent test oracle for Gregorian cross-checks; the library implementation must remain its own integer arithmetic.

## Pull requests and bug reports

Describe the observed behavior, expected behavior, Ruby version, and a minimal date example. For pull requests, explain the calendar convention and cite a reliable reference if the change follows a published rule. Keep changes focused and update relevant docs and executable examples.

## Architecture expectations

Runtime dependencies should remain zero unless a concrete need is demonstrated. Public API belongs under `JWCalendar::`; calculations must be deterministic and free of mutable process-global state. Do not add timezone behavior to `CivilDate`.
