# Calibration of the dominance noise (sigma_nu and n)

Theoretical, data-free. For every candidate
`(sigma_nu, n, beta, sigma_eps)`, evaluates the scenario-I risk over an
internal grid of dominance levels `rho`, keeps its worst case (max over
rho), and reports the maximum information loss (reached at rho = 1,
hence set by `sigma_nu` alone). The returned table is the decision
surface of step 2: feed it to
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for the risk
heat-map, to
[`pm_suggest_n()`](https://inseefrlab.github.io/dominoise/reference/pm_suggest_n.md)
for the largest admissible `n`, then lock the choice with
[`pm_commit_dominance()`](https://inseefrlab.github.io/dominoise/reference/pm_commit_dominance.md).

## Usage

``` r
pm_calib_dominance(
  params = NULL,
  sigma_nu = NULL,
  n = NULL,
  beta = NULL,
  sigma_eps = NULL,
  level = 0.95,
  rho = NULL
)
```

## Arguments

- params:

  Optional `pm_params`. When supplied, `sigma_eps` and `beta` default to
  its values.

- sigma_nu, n:

  Numeric vectors of candidate values. Default to `seq(0.05, 0.5, 0.05)`
  and `seq(3, 12, 0.5)`.

- beta:

  Accuracy threshold(s) of scenario I. Default to the `dominance` policy
  of `params`, or to `c(0.05, 0.1, 0.15, 0.2, 0.25)` (as in the
  differencing step).

- sigma_eps:

  Fixed differencing noise. Default to `params$mechanism$sigma_eps`, or
  `0` when no `params` is given.

- level:

  Confidence level for the CI loss metric (default 0.95).

- rho:

  Internal grid of dominance levels used to locate the worst case.
  Default `seq(0, 1, 0.02)`.

## Value

A `data.frame` of class `pm_calib_dominance`, one row per
`(sigma_nu, n, beta, sigma_eps)`, with columns `risk_max`, `rho_at_max`,
`EZ_max`, `CI_max` (the last two in percent).

## Details

Like
[`pm_calib_diff()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_diff.md),
calling it with everything at `NULL` returns a default exploration grid.

## Examples

``` r
# default exploration
grid <- pm_calib_dominance()
grid
#> <pm_calib_dominance>  2000 rows (rho-resolved)
#>   rho      : 50 values in [0.02, 1]
#>   sigma_nu : 5 values in [0.1, 0.5]
#>   n        : 4 values in [3, 12]
#>   beta     : 0.1, 0.2
#>   sigma_eps: 0
#>   CI level : 95%
#> 
#>   worst-case risk & loss range per combination (40 total):
#>  sigma_nu sigma_eps  n beta rho_at_max_risk risk_max EZ_min EZ_max CI_min
#>       0.1         0  3  0.1            0.98    0.691      0  7.979      0
#>       0.1         0  3  0.2            0.98    0.958      0  7.979      0
#>       0.1         0  6  0.1            0.96    0.722      0  7.979      0
#>       0.1         0  6  0.2            0.96    0.972      0  7.979      0
#>       0.1         0  9  0.1            0.96    0.766      0  7.979      0
#>       0.1         0  9  0.2            0.94    0.987      0  7.979      0
#>       0.1         0 12  0.1            0.96    0.806      0  7.979      0
#>       0.1         0 12  0.2            0.90    0.998      0  7.979      0
#>  CI_max
#>    19.6
#>    19.6
#>    19.6
#>    19.6
#>    19.6
#>    19.6
#>    19.6
#>    19.6
#>   ... 32 more; call summary() for the full digest.
summary(grid)
#>  sigma_nu sigma_eps  n beta rho_at_max_risk risk_max EZ_min EZ_max CI_min
#>       0.1         0  3  0.1            0.98    0.691      0  7.979  0.000
#>       0.1         0  3  0.2            0.98    0.958      0  7.979  0.000
#>       0.1         0  6  0.1            0.96    0.722      0  7.979  0.000
#>       0.1         0  6  0.2            0.96    0.972      0  7.979  0.000
#>       0.1         0  9  0.1            0.96    0.766      0  7.979  0.000
#>       0.1         0  9  0.2            0.94    0.987      0  7.979  0.000
#>       0.1         0 12  0.1            0.96    0.806      0  7.979  0.000
#>       0.1         0 12  0.2            0.90    0.998      0  7.979  0.000
#>       0.2         0  3  0.1            0.94    0.404      0 15.958  0.000
#>       0.2         0  3  0.2            0.94    0.712      0 15.958  0.000
#>       0.2         0  6  0.1            0.94    0.465      0 15.958  0.000
#>       0.2         0  6  0.2            0.92    0.790      0 15.958  0.000
#>       0.2         0  9  0.1            0.94    0.527      0 15.958  0.000
#>       0.2         0  9  0.2            0.92    0.862      0 15.958  0.000
#>       0.2         0 12  0.1            0.94    0.587      0 15.958  0.000
#>       0.2         0 12  0.2            0.90    0.922      0 15.958  0.000
#>       0.3         0  3  0.1            0.92    0.290      0 23.937  0.000
#>       0.3         0  3  0.2            0.92    0.543      0 23.937  0.000
#>       0.3         0  6  0.1            0.90    0.358      0 23.937  0.000
#>       0.3         0  6  0.2            0.90    0.653      0 23.937  0.000
#>       0.3         0  9  0.1            0.92    0.421      0 23.937  0.000
#>       0.3         0  9  0.2            0.90    0.746      0 23.937  0.000
#>       0.3         0 12  0.1            0.92    0.484      0 23.937  0.000
#>       0.3         0 12  0.2            0.90    0.827      0 23.937  0.000
#>       0.4         0  3  0.1            0.88    0.231      0 31.915  0.001
#>       0.4         0  3  0.2            0.88    0.443      0 31.915  0.001
#>       0.4         0  6  0.1            0.88    0.300      0 31.915  0.000
#>       0.4         0  6  0.2            0.88    0.563      0 31.915  0.000
#>       0.4         0  9  0.1            0.90    0.364      0 31.915  0.000
#>       0.4         0  9  0.2            0.90    0.662      0 31.915  0.000
#>       0.4         0 12  0.1            0.90    0.418      0 31.915  0.000
#>       0.4         0 12  0.2            0.90    0.754      0 31.915  0.000
#>       0.5         0  3  0.1            0.86    0.194      0 39.894  0.001
#>       0.5         0  3  0.2            0.86    0.377      0 39.894  0.001
#>       0.5         0  6  0.1            0.86    0.263      0 39.894  0.000
#>       0.5         0  6  0.2            0.86    0.501      0 39.894  0.000
#>       0.5         0  9  0.1            0.88    0.326      0 39.894  0.000
#>       0.5         0  9  0.2            0.88    0.608      0 39.894  0.000
#>       0.5         0 12  0.1            0.90    0.383      0 39.894  0.000
#>       0.5         0 12  0.2            0.88    0.695      0 39.894  0.000
#>  CI_max
#>  19.600
#>  19.600
#>  19.600
#>  19.600
#>  19.600
#>  19.600
#>  19.600
#>  19.600
#>  39.199
#>  39.199
#>  39.199
#>  39.199
#>  39.199
#>  39.199
#>  39.199
#>  39.199
#>  58.799
#>  58.799
#>  58.799
#>  58.799
#>  58.799
#>  58.799
#>  58.799
#>  58.799
#>  78.399
#>  78.399
#>  78.399
#>  78.399
#>  78.399
#>  78.399
#>  78.399
#>  78.399
#>  97.998
#>  97.998
#>  97.998
#>  97.998
#>  97.998
#>  97.998
#>  97.998
#>  97.998

# at a committed sigma_eps
para <- pm_commit_diff(pm_params())
#> Differencing step committed: beta = 0.05, tau = 0.95  ->  sigma_eps = 0.0255
#>   loss floor at rho -> 0:  E|Z| = 2.04%,  upper 95% CI = 5.00%
grid <- pm_calib_dominance(para)
```
