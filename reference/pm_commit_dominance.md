# Commit the dominance decision (sigma_nu and n) into the parameter object

Closes calibration step 2: records the chosen `sigma_nu` and `n`,
together with the scenario-I policy (`beta`, `tau`), into the
`pm_params` object. This is the single place where step 2 mutates
`params`.

## Usage

``` r
pm_commit_dominance(
  params,
  sigma_nu,
  n,
  beta = NULL,
  tau = NULL,
  level = 0.95,
  rho = NULL
)
```

## Arguments

- params:

  A `pm_params` object with `sigma_eps` set.

- sigma_nu, n:

  The chosen values (single values). Recall the calibration rule of step
  2: keep the *largest* `n` whose worst-case risk still meets the
  ceiling, so as to spare cells of intermediate dominance (see
  [`pm_calib_dominance()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_dominance.md)
  and the trade-off map
  [`pm_plot_tradeoff()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_tradeoff.md)).

- beta, tau:

  Scenario-I accuracy threshold and risk ceiling. Default to the
  `dominance` policy already stored in `params`.

- level:

  Confidence level for the reported CI loss (default 0.95).

- rho:

  Grid used to locate the worst case over rho. Default
  `seq(0.001, 1, 0.001)`.

## Value

The updated `pm_params`, invisibly.

## Details

Requires `sigma_eps` to be already set (step 1), since both the
scenario-I risk and the information loss depend on it. The function
reports the resulting worst-case risk over `rho`, where that worst case
occurs, and the range of the information loss – from its floor (rho -\>
0, driven by `sigma_eps` alone) to its ceiling (rho = 1, driven by
`sigma_nu`). A warning is raised when the worst-case risk exceeds `tau`:
the values are still recorded, the producer being free to accept the
overshoot knowingly.

## Examples

``` r
para <- pm_commit_diff(pm_params())
#> Differencing step committed: beta = 0.05, tau = 0.95  ->  sigma_eps = 0.0255
#>   loss floor at rho -> 0:  E|Z| = 2.04%,  upper 95% CI = 5.00%
para <- pm_commit_dominance(para, sigma_nu = 0.3, n = 6)
#> Dominance step committed: sigma_nu = 0.3, n = 6 (beta = 0.2, sigma_eps = 0.0255107)
#>   worst-case scenario-I risk: 0.648, reached at rho = 0.901
#>   information loss E|Z| : 2.04% (rho -> 0) to 24.02% (rho = 1)
#>   information loss CI95%: 5.00% (rho -> 0) to 59.01% (rho = 1)
#>   ceiling tau = 0.9: met (margin 0.252).
para
#> <pm_params>
#>   policy
#>     dominance : beta = 0.2, tau = 0.9
#>     p%-rule   : beta = 0.1, tau = 0.9, s = 0.95
#>     diff      : beta = 0.05, tau = 0.95
#>   parameters of the mechanism
#>     sigma_nu  = 0.3
#>     sigma_eps = 0.02551067
#>     n         = 6
```
