# Print method for a dominance calibration grid

Shows the grid's extent (rho and the parameter axes) and the worst-case
risk / loss-range digest produced by
[`summary()`](https://rdrr.io/r/base/summary.html).

## Usage

``` r
# S3 method for class 'pm_calib_dominance'
print(x, rows = 8, ...)
```

## Arguments

- x:

  A `pm_calib_dominance` table.

- rows:

  Number of summary rows to display (default 8).

- ...:

  Ignored.

## Value

`x`, invisibly.
