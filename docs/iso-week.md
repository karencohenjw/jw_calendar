# ISO week dates

An ISO week begins Monday. Week 1 is the week containing January 4 (equivalently the year's first Thursday). Therefore dates near New Year can have a week-year different from their Gregorian calendar year.

`CivilDate#iso_week` returns `ISO::WeekDate`. `WeekDate#to_date` returns the corresponding proleptic Gregorian date; construction validates whether the year has 52 or 53 weeks.

```ruby
date = JWCalendar::CivilDate.gregorian(2027, 1, 1)
date.iso_week.to_s # => "2026-W53-5"
```

The ISO weekday is Monday=1 through Sunday=7. The week-year is determined by moving to the date's Thursday, which is constant-time. Normative rules are in [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html).
