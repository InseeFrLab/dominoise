# Plot method for a differencing calibration grid

Draws the risk-utility frontier of the differencing step: the level risk
ceiling `tau` (guaranteed maximum differencing risk) against the
relative loss (Z) level it costs (either expectation of \|Z\| or upper
bound of the confidence interval of it), one curve per `beta`.

## Usage

``` r
# S3 method for class 'pm_calib_diff'
plot(x, loss = c("CI", "EZ"), ...)
```

## Arguments

- x:

  A `pm_calib_diff` grid, as returned by
  [`pm_calib_diff()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_diff.md).

- loss:

  One of `"CI"` (for upper bound of the confidence interval), `"EZ"`
  (for expectation of the absolute relative loss \|Z\|): which loss
  metric to use on the x-axis.

- ...:

  Ignored, for compatibility with the
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) generic.

## Value

The `ggplot` object, invisibly.

## Examples

``` r
plot(pm_calib_diff())
```
