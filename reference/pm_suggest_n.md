# Largest admissible shape parameter n

Implements the step-2 calibration rule. The worst-case scenario-I risk
increases with `n`, while the information loss decreases with `n` at
every `rho < 1` and is unchanged at `rho = 1`. Both objectives are
therefore monotone and opposite in `n`: there is no interior optimum,
and the best choice is the upper edge of the admissible set,
`n_max = sup{n : max_rho mu_I <= tau}`. Because the risk is monotone,
that edge is found by root-finding rather than by a grid search.

## Usage

``` r
pm_suggest_n(
  params = NULL,
  sigma_nu = NULL,
  beta = NULL,
  tau = NULL,
  sigma_eps = NULL,
  margin = 0,
  n_range = c(1, 30),
  integer = FALSE,
  level = 0.95,
  rho = NULL
)
```

## Arguments

- params:

  Optional `pm_params`; supplies `sigma_eps`, `beta` and `tau`.

- sigma_nu:

  Numeric vector of candidate values. Default `seq(0.05, 0.5, 0.05)`.

- beta, tau:

  Scenario-I threshold and ceiling. Default to the `dominance` policy of
  `params`.

- sigma_eps:

  Fixed differencing noise. Defaults to `params$mechanism$sigma_eps`.

- margin:

  Safety margin in \[0,1): the effective ceiling is
  `tau * (1 - margin)`. `n_max` is a boundary solution with zero slack,
  so a small margin guards against later revisions of the policy.
  Default 0.

- n_range:

  Search interval for `n`. Default `c(1, 30)`.

- integer:

  If `TRUE`, round `n_max` down to an integer – the only conservative
  rounding, the risk being increasing in `n`.

- level:

  Confidence level for the reported CI loss (default 0.95).

- rho:

  Grid used to locate the worst case. Default `seq(0.001, 1, 0.001)`.

## Value

A `data.frame` with one row per `sigma_nu`: `n_max`, `risk_at_n_max`,
and the information loss at `rho = 1` and at the dominance threshold
`1 - beta`. `n_max` is `NA` when no `n` meets the ceiling (raise
`sigma_nu`), and the upper end of `n_range` when the whole range
qualifies.

## Details

The rule holds whatever the dominance profile of the table: since
utility improves at every `rho`, no weighting by the actual distribution
of `rho` could favour a smaller `n`.

Note this determines `n` *given* `sigma_nu`. Every point of the returned
frontier meets the ceiling exactly, so choosing among them is a pure
utility arbitrage – larger `sigma_nu` costs more at `rho = 1` but spares
cells of intermediate dominance. The reported losses are there to settle
it.

## Examples

``` r
para <- pm_commit_diff(pm_params())
#> Differencing step committed: beta = 0.05, tau = 0.95  ->  sigma_eps = 0.0255
#>   loss floor at rho -> 0:  E|Z| = 2.04%,  upper 95% CI = 5.00%
pm_suggest_n(para, sigma_nu = c(0.3, 0.4, 0.5))
#>   sigma_nu  sigma_eps beta tau target    n_max risk_at_n_max  EZ_rho1
#> 1      0.3 0.02551067  0.2 0.9    0.9 15.76402           0.9 24.02292
#> 2      0.4 0.02551067  0.2 0.9    0.9 18.42437           0.9 31.98022
#> 3      0.5 0.02551067  0.2 0.9    0.9 20.37695           0.9 39.94612
#>   EZ_rho_dom  CI_rho1 CI_rho_dom
#> 1   2.155793 59.01113   5.295600
#> 2   2.101572 78.55784   5.162408
#> 3   2.078914 98.12567   5.106749
```
