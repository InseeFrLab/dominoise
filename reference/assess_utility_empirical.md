# Observed information loss

Measures the perturbation actually undergone by the table, and compares
it with the theoretical expectation of Proposition 3 evaluated at each
cell's own dominance. A close match is the natural consistency check:
the mechanism is analytical, so the realised loss should track the
predicted one.

## Usage

``` r
assess_utility_empirical(x, by = NULL, thresholds = c(5, 10, 20))
```

## Arguments

- x:

  A table returned by
  [`pm_perturb()`](https://inseefrlab.github.io/dominoise/reference/pm_perturb.md).

- by:

  Optional column name(s) to break the summary down by (e.g. a
  publication stratum, or a dominance band built beforehand).

- thresholds:

  Relative deviations (in percent) whose exceedance rate is reported.

## Value

A `data.frame`: number of cells, mean and median absolute relative
deviation, quantiles, maximum, relative RMSE, exceedance rates, and the
theoretical mean absolute loss averaged over the observed dominance.
