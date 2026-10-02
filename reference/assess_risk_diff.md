# Compute the upper bound of the differencing risk.

Compute the upper bound of the differencing risk.

## Usage

``` r
assess_risk_diff(sigma_eps, beta)
```

## Arguments

- sigma_eps:

  double

- beta:

  double

## Value

double vector

## See also

[dominoise-package](https://inseefrlab.github.io/dominoise/reference/dominoise-package.md)
paper's proposition 7

## Examples

``` r
assess_risk_diff(sigma_eps = 0.1, beta = 0.2)
#> [1] 0.9544997
```
