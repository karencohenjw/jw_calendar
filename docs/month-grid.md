# Month grids

`Grid::MonthGrid` produces rows of seven immutable cells. Each nonblank cell has a `CivilDate`, a current-month flag, weekday, zero-based row index, and zero-based column index.

`week_start` accepts `:monday`, `:sunday`, or an ISO weekday integer. By default the grid has the natural four, five, or six weeks needed to contain all dates. Set `fixed_weeks: 6` for a 42-cell layout. A shorter fixed size that cannot contain the month raises `ArgumentError`.

With `include_adjacent: true`, cells before and after the month are real dates. With `false`, those cells are blank (`date == nil`) while retaining their grid position. `#to_h` returns JSON-friendly row and weekday data; presentation remains the caller's responsibility.
