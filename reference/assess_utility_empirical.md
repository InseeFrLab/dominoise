# Observed information loss

Measures the perturbation actually undergone by the table, and compares
it with the theoretical expectation evaluated at each cell's own
dominance. A close match is the natural consistency check: the mechanism
is analytical, so the realised loss should track the predicted one.

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

## See also

[dominoise-package](https://inseefrlab.github.io/dominoise/reference/dominoise-package.md)
paper's proposition 3

## Examples

``` r
set.seed(123)
para <- suppressMessages(
  pm_commit_dominance(pm_commit_diff(pm_params()), sigma_nu = 0.4, n = 4)
)
tab <- data.frame(turnover = runif(500, 100, 1000), ck = runif(500))
tab$x1 <- tab$turnover * runif(500, 0.2, 1)
tab$x2 <- (tab$turnover - tab$x1) * runif(500)
res <- pm_perturb(tab, "turnover", "x1", "ck", para, x2 = "x2")
assess_utility_empirical(res)
#>   n_cells mean_abs_dev median_abs_dev q90_abs_dev max_abs_dev rmse_rel
#> 1     500     7.986784       3.836578    21.08892    99.10279 13.89703
#>   theo_mean_abs pct_above_5 pct_above_10 pct_above_20
#> 1      8.379267        41.4         23.8         10.6
```
