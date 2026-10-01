# Reform calendars

Historical adoption of Gregorian rules happened on different dates in different places. A reform profile therefore requires an explicit local cutover pair:

```ruby
reform = JWCalendar::Calendars::ReformCalendar.new(
  last_julian_date: [1582, 10, 4],
  first_gregorian_date: [1582, 10, 15]
)
```

The pair must represent consecutive absolute days. Labels after the last Julian label and before the first Gregorian label raise `ReformGapError`. `date` selects the appropriate underlying calendar for labels on either side; `from_jdn` does the inverse. Optional constructors `.papal` and `.british_empire` are named profiles for commonly cited transitions, not universal history settings.

`CivilDate` intentionally records only its underlying proleptic Gregorian or Julian system. Keep the `ReformCalendar` instance with application data when the selected jurisdiction's reform rule matters.
