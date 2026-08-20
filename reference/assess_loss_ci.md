# Confidence-interval bound of the relative loss Z

Upper bound `L(rho) = q * sqrt(rho^(2n) sigma_nu^2 + sigma_eps^2)` of
the level-`level` confidence interval `[-L(rho), L(rho)]` of Z
(Definition 4 of the paper), with `q` the `(1+level)/2` quantile of the
standard normal. The interval is symmetric, so this single value gives
both bounds.

## Usage

``` r
assess_loss_ci(rho, sigma_nu, sigma_eps, n, level = 0.95)
```

## Arguments

- rho:

  Dominance share X1/Y in (0,1\]. Recycled.

- sigma_nu, sigma_eps, n:

  Mechanism parameters. Recycled.

- level:

  Confidence level (default 0.95).

## Value

The upper bound L(rho) as a relative quantity.

## Examples

``` r
assess_loss_ci(rho = 1, sigma_nu = 0.3, sigma_eps = 0.03, n = 6)
#> [1] 0.5909218
```
