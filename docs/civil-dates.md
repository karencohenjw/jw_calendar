# Civil dates

`CivilDate` stores `(year, month, day, calendar)` and no time-of-day fields. Its default constructor calendar is Gregorian; explicit class constructors are available:

```ruby
gregorian = JWCalendar::CivilDate.gregorian(2027, 1, 1)
julian = JWCalendar::CivilDate.julian(1582, 10, 4)
```

Years are positive integers (1 CE and later). Invalid month/day combinations raise `InvalidDateError`; an unsupported calendar raises `InvalidCalendarError`. The date is frozen after validation.

Ordering compares absolute JDN values, so distinct calendar labels can represent the same day and compare equally in ordering. `==` and `hash` include the calendar system, which keeps each labelled representation distinct as a value. Arithmetic preserves the source calendar system. Converting a day to a Gregorian/Julian label is an explicit operation through `CalendarConverter` or `CivilDate.from_jdn`.

No conversion to midnight UTC is implied. If an application starts from an instant, it must apply its own timezone policy before creating a civil date.
