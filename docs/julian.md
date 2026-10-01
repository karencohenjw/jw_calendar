# Julian calendar

The Julian civil calendar inserts a leap day every four years. It is implemented separately from Gregorian arithmetic under `Calendars::Julian`.

Both calendar systems map to JDN, which lets `CalendarConverter` translate a date label while preserving its absolute day:

```ruby
day = JWCalendar::CivilDate.gregorian(1582, 10, 15)
JWCalendar::Conversion::CalendarConverter.convert(day, to: :julian).to_s
# => "1582-10-05"
```

“Julian calendar” refers to a civil calendar rule. “Julian Day Number” refers to an integer day count; the shared word does not make them the same concept. The library supports positive year labels and does not encode historical jurisdiction-specific adoption dates unless a `ReformCalendar` is selected.
