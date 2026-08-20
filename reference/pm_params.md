# Create the perturbation-parameter object containing all the parameters of the noise.

Create the perturbation-parameter object containing all the parameters
of the noise.

## Usage

``` r
pm_params(
  beta_dominance = 0.2,
  tau_dominance = 0.9,
  beta_prule = 0.1,
  tau_prule = 0.9,
  s_prule = 0.95,
  beta_diff = 0.05,
  tau_diff = 0.95,
  sigma_nu = NA_real_,
  sigma_eps = NA_real_,
  n = NA_real_
)
```

## Arguments

- beta_dominance, tau_dominance:

  Accuracy threshold and risk ceiling for scenario I (dominance rule).
  Defaults to 0.2 / 0.5.

- beta_prule, tau_prule, s_prule:

  Threshold, ceiling and cumulated share of the two largest contributors
  for scenario II (p%-rule). `s_prule = 0.95` is the relaxed case IIb in
  the paper; `1` would be the worst case IIa. Defaults to 0.1 / 0.9 /
  0.95.

- beta_diff, tau_diff:

  Threshold and ceiling for the differencing scenario. Defaults: 0.05 /
  0.95.

- sigma_nu, sigma_eps, n:

  Mechanism parameters, filled in during calibration. Left as `NA` until
  decided.

## Value

pm_params object

## Examples

``` r
para <- pm_params()
para
#> <pm_params>
#>   policy
#>     dominance : beta = 0.2, tau = 0.9
#>     p%-rule   : beta = 0.1, tau = 0.9, s = 0.95
#>     diff      : beta = 0.05, tau = 0.95
#>   parameters of the mechanism
#>     sigma_nu  = <not set>
#>     sigma_eps = <not set>
#>     n         = <not set>
```
