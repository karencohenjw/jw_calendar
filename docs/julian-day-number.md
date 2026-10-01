# JDN, JD, and MJD

`CivilDate#to_jdn` returns the integer Julian Day Number associated with that date at astronomical noon. JDNs provide a common integer coordinate for Gregorian and Julian labels.

JD is fractional. The start of a civil day at midnight is half a day before its noon-labelled integer: `JD = JDN - 1/2`. The inverse splits an exact JD into a date and a fraction since midnight. MJD uses `MJD = JD - 2,400,000.5`; at midnight, MJD equals `JDN - 2,400,001`.

The conversion methods accept or return rational values. For example, a quarter-day offset should be supplied as `Rational(1, 4)` when exactness matters. A fraction denotes a mathematical fraction of a day; this API does not model leap seconds or a timescale such as UTC, TT, or TAI.

For background on Julian date conventions, see the [U.S. Naval Observatory](https://aa.usno.navy.mil/data/JulianDate).
