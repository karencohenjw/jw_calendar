# Proleptic Gregorian calendar

The Gregorian leap-year rule is divisibility by 4, except century years must also be divisible by 400. Thus 1600 and 2000 are leap years, while 1700, 1800, 1900, and 2100 are not.

`Calendars::Gregorian` uses closed-form integer arithmetic to map a valid positive-year label to JDN and invert an integer JDN. The proleptic model applies Gregorian rules consistently before historical adoption; it does not itself model a jurisdiction's changeover. For a historical Julian-to-Gregorian switch, use `ReformCalendar`.

Weekday derives from `JDN mod 7`, with Monday=1 and Sunday=7. Day-of-year is computed from the same validated Gregorian month lengths. These operations do not iterate from an epoch.

Ruby's standard `Date` is used in tests as an independent cross-check, not as the implementation: [Date documentation](https://docs.ruby-lang.org/en/master/Date.html).
