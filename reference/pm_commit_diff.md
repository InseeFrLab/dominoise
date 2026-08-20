# Commit the differencing decision into the parameter object

Once `beta_diff` and `tau_diff` are chosen (typically after exploring
with
[`pm_calib_diff()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_diff.md)),
this fills `sigma_eps` in the `pm_params` object and records the two
policy values. It is the single place where step 1 mutates `params`.

## Usage

``` r
pm_commit_diff(
  params,
  beta = params$policy$diff$beta,
  tau = params$policy$diff$tau,
  level = 0.95
)
```

## Arguments

- params:

  A `pm_params` object.

- beta, tau:

  The chosen threshold and ceiling. Default to the values already stored
  in the `diff` policy. Must be single values.

- level:

  Confidence level used only for the informative message.

## Value

The updated `pm_params` (returned invisibly).

## Examples

``` r
parameters <- pm_params()

# beta and tau already set in the pm_params object:
parameters <- pm_commit_diff(parameters)
#> Differencing step committed: beta = 0.05, tau = 0.95  ->  sigma_eps = 0.0255
#>   loss floor at rho -> 0:  E|Z| = 2.04%,  upper 95% CI = 5.00%
parameters
#> <pm_params>
#>   policy
#>     dominance : beta = 0.2, tau = 0.9
#>     p%-rule   : beta = 0.1, tau = 0.9, s = 0.95
#>     diff      : beta = 0.05, tau = 0.95
#>   parameters of the mechanism
#>     sigma_nu  = <not set>
#>     sigma_eps = 0.02551067
#>     n         = <not set>

# if an another choice is preferred (after calibration search)
parameters <- pm_commit_diff(parameters, beta = 0.1, tau = 0.9)
#> Differencing step committed: beta = 0.1, tau = 0.9  ->  sigma_eps = 0.0608
#>   loss floor at rho -> 0:  E|Z| = 4.85%,  upper 95% CI = 11.92%
parameters
#> <pm_params>
#>   policy
#>     dominance : beta = 0.2, tau = 0.9
#>     p%-rule   : beta = 0.1, tau = 0.9, s = 0.95
#>     diff      : beta = 0.1, tau = 0.9
#>   parameters of the mechanism
#>     sigma_nu  = <not set>
#>     sigma_eps = 0.06079568
#>     n         = <not set>
```
