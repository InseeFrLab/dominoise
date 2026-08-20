# Perturb an aggregated table

Applies the mechanism of Definition 2 to a table of sums:
`Y' = Y (1 + rho^n nu + eps)` with `rho = X1 / Y`. The draws are
obtained from the cell keys via
[`pm_draws()`](https://inseefrlab.github.io/dominoise/reference/pm_draws.md),
so the perturbation is reproducible: re-running on the same cells and
the same indicator returns the same values.

## Usage

``` r
pm_perturb(
  data,
  total,
  x1,
  ck_var,
  params,
  indicator = NULL,
  operation = "sum",
  x2 = NULL,
  reduce_key = FALSE,
  key_digits = 9L
)
```

## Arguments

- data:

  A `data.frame` of aggregated data.

- total, x1:

  Column names (strings): the aggregate and the largest contribution, in
  the same unit.

- ck_var:

  Column name of the aggregated cell key.

- params:

  A fully calibrated `pm_params` object.

- indicator:

  Name of the indicator; defaults to the `total` column name.

- operation:

  Aggregation name entering the hash (default `"sum"`).

- x2:

  Optional column name of the second largest contribution. When given,
  the share `rho2 = X2 / Y` is added, enabling the scenario-II
  assessment.

- reduce_key:

  If `TRUE`, reduce `ck_var` to its fractional part (use it when the
  column holds the raw sum of individual keys, Definition 6). If `FALSE`
  (default), keys must already lie in \[0;1\].

- key_digits:

  Decimals used to stringify the key before hashing (default 9).

## Value

`data` with added columns `rho`, `rho2` (when `x2` is given), `ck_nu`,
`ck_eps`, and the perturbed total named `<total>_pert`. Calibration
parameters and hashing settings are attached as the `pm_meta` attribute.

## Details

The mechanism is defined for strictly positive totals. Cells with a
non-positive total are left unperturbed and flagged, with a warning:
being multiplicative, the noise protects neither zeros nor near-zero
values.

## Examples

``` r
para <- pm_commit_dominance(pm_commit_diff(pm_params()), sigma_nu = 0.4, n = 4)
#> Differencing step committed: beta = 0.05, tau = 0.95  ->  sigma_eps = 0.0255
#>   loss floor at rho -> 0:  E|Z| = 2.04%,  upper 95% CI = 5.00%
#> Dominance step committed: sigma_nu = 0.4, n = 4 (beta = 0.2, sigma_eps = 0.0255107)
#>   worst-case scenario-I risk: 0.482, reached at rho = 0.875
#>   information loss E|Z| : 2.04% (rho -> 0) to 31.98% (rho = 1)
#>   information loss CI95%: 5.00% (rho -> 0) to 78.56% (rho = 1)
#>   ceiling tau = 0.9: met (margin 0.418).
tab <- data.frame(turnover = c(1000, 500), x1 = c(850, 120), ck = c(0.12, 0.87))
pm_perturb(tab, total = "turnover", x1 = "x1", ck_var = "ck", params = para)
#>   turnover  x1   ck  rho     ck_nu    ck_eps turnover_pert
#> 1     1000 850 0.12 0.85 0.3001429 0.0560337      850.0540
#> 2      500 120 0.87 0.24 0.6236417 0.2439149      491.3599
```
