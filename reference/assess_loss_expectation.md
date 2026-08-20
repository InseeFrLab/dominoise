# Conditional expectation of the absolute relative loss \|Z\|

`E(|Z| | P = rho) = sqrt(2 (rho^(2n) sigma_nu^2 + sigma_eps^2) / pi)`
(Proposition 3 of the paper): the average relative perturbation
undergone by a cell of dominance `rho`. Contrary to the differencing
step – where letting rho -\> 0 makes the sigma_nu term vanish – the
sigma_nu contribution is kept in full here.

## Usage

``` r
assess_loss_expectation(rho, sigma_nu, sigma_eps, n)
```

## Arguments

- rho:

  Dominance share X1/Y in (0,1\]. Recycled.

- sigma_nu, sigma_eps, n:

  Mechanism parameters. Recycled.

## Value

E(\|Z\| \| rho) as a relative quantity (multiply by 100 for percent).

## Examples

``` r
assess_loss_expectation(rho = 1, sigma_nu = 0.3, sigma_eps = 0.03, n = 6)
#> [1] 0.2405592
```
