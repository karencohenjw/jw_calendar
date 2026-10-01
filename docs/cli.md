# Command-line interface

The `jwcalendar` executable wraps the library with stable, deterministic commands:

```text
jwcalendar inspect DATE [--calendar gregorian|julian] [--json]
jwcalendar iso-week DATE [--calendar gregorian|julian] [--json]
jwcalendar jdn DATE [--calendar gregorian|julian] [--json]
jwcalendar convert DATE [--from gregorian|julian] [--to gregorian|julian] [--json]
jwcalendar grid YYYY-MM [--week-start monday|sunday] [--fixed-weeks 4|5|6] [--no-adjacent] [--json]
jwcalendar boundary YEAR [--json]
```

Structured commands accept `--json`. Invalid arguments are written to standard error and return exit status 2. The default output is intended for people; scripts should request JSON. JDN is emitted as an integer, and JD/MJD at midnight as exact rational strings.
