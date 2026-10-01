# Architecture

## Public layers

- `CivilDate` stores a validated immutable calendar label and maps it to an integer JDN.
- `Calendars::Gregorian` and `Calendars::Julian` own their respective leap rules and JDN algorithms.
- `Conversion` handles cross-calendar and ordinal/JD representations.
- `ISO::WeekDate` handles ISO week-year value conversion.
- `Grid`, `DateRange`, and `Boundary` compose the date primitives without owning a clock or timezone.
- `CLI::Runner` is a small standard-library interface around the public operations.

The library uses positive civil years beginning at 1 CE and has no runtime dependencies. Constructors validate inputs before storing them. Value objects freeze their instance state; there is no process-global calendar selection.

## Determinism

All date calculations use integers. JD/MJD fractions use `Rational` when produced by the library or supplied exactly. Nothing reads local time, environment locale, or system timezone. Range enumeration is lazy; a grid allocates only its four-to-six rows.

## Complexity

Leap checks, conversion, weekday, ordinal lookup, comparison, and adding a fixed number of days are O(1). A month grid is O(1) in its fixed maximum size. Range traversal is O(n) time and O(1) extra space, excluding objects yielded to the caller. Boundary reports take O(days in the requested year/range) because they emit date-level ISO conditions.

## References

- ISO week numbering is specified by [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html).
- Julian date conventions are described by the [U.S. Naval Observatory](https://aa.usno.navy.mil/data/JulianDate).
- Ruby's `Date` is used only as a test oracle for Gregorian arithmetic: [Ruby Date documentation](https://docs.ruby-lang.org/en/master/Date.html).
