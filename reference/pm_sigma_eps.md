# Smallest `sigma_eps` guaranteeing the differencing-risk ceiling

Closed-form inversion of the worst-case upper bound of the differencing
risk.

## Usage

``` r
pm_sigma_eps(beta, tau)
```

## Arguments

- beta, tau:

  Numeric. Accuracy threshold and risk ceiling.

## Value

A numeric vector of `sigma_eps` values, vectorised over `beta`/`tau`.

## See also

[dominoise-package](https://inseefrlab.github.io/dominoise/reference/dominoise-package.md)
(Proposition 7 of the paper).

## Examples

``` r
pm_sigma_eps(beta = 0.05, tau = 0.95)
#> [1] 0.02551067
pm_sigma_eps(beta = c(0.05, 0.1), tau = 0.9)
#> [1] 0.03039784 0.06079568
```
