# Plot method for a dominance calibration grid

Thin dispatcher over the three calibration plots.

## Usage

``` r
# S3 method for class 'pm_calib_dominance'
plot(x, type = c("tradeoff", "profile", "worst"), ...)
```

## Arguments

- x:

  A `pm_calib_dominance` table.

- type:

  `"tradeoff"` (Figure 4, default), `"profile"` (Figure 2) or `"worst"`
  (Figure 3, middle panel).

- ...:

  Passed on to the underlying plotting function.

## Value

A `ggplot` object.
