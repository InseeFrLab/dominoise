# Observed disclosure risk

For each cell, evaluates whether the attack of a given scenario would in
fact have succeeded on the realised perturbation – scenario I:
`|Y' - X1| / X1 < beta`; scenario II: `|(Y' - X2) - X1| / X1 < beta` –
and compares the observed success rate with the theoretical probability
`mu(rho)` averaged over the table. The two should agree: the realised
rate is one draw from the probability the mechanism guarantees.

## Usage

``` r
assess_risk_empirical(x, scenario = c("I", "II"), beta = NULL, by = NULL)
```

## Arguments

- x:

  A table returned by
  [`pm_perturb()`](https://inseefrlab.github.io/dominoise/reference/pm_perturb.md).

- scenario:

  `"I"` (default) or `"II"`.

- beta:

  Accuracy threshold. Defaults to the matching policy of the parameter
  object.

- by:

  Optional column name(s) to break the summary down by.

## Value

A `data.frame` with the number of cells, the observed success rate (in
percent), the mean theoretical risk, and the maximum theoretical risk.

## Details

Scenario II requires the `x2` column to have been declared in
[`pm_perturb()`](https://inseefrlab.github.io/dominoise/reference/pm_perturb.md),
which adds the `rho2` share the theoretical measure needs. The
differencing scenario is not assessed here: it bears on pairs of cells,
not on single cells, and is controlled a priori by the upper bound of
the metric.

## See also

[dominoise-package](https://inseefrlab.github.io/dominoise/reference/dominoise-package.md)
paper's proposition 7

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
assess_risk_empirical(res, scenario = "I")
#>   scenario beta n_cells observed_pct theo_mean  theo_max
#> 1        I  0.2     500         13.4 0.1360245 0.4822485
assess_risk_empirical(res, scenario = "II")
#>   scenario beta n_cells observed_pct theo_mean  theo_max
#> 1       II  0.1     500         15.4 0.1615296 0.8464624
```
