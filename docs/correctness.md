# Correctness model

The core invariant is that a Gregorian or Julian label maps to one integer JDN and inverse conversion returns the same label. Cross-calendar conversion preserves JDN. Weekday derives from the same absolute day. ISO conversion uses the Monday containing January 4 and round-trips every sampled day.

Tests cover leap centuries, known historical and epoch values, New Year ISO transitions, deterministic year samples, cutover gaps, 7-column grids, exact JD/MJD fractions, and the Julian/Gregorian offset change after February in century years such as 1700. For supported positive Gregorian years, the test suite compares JDN results with Ruby's independent `Date` implementation configured for proleptic Gregorian rules.

The supported civil label domain is 1 CE onward, with no year zero. Time scales, leap seconds, timezone interpretation, and locale-specific week displays are outside this version's correctness claim.
