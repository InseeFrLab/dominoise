# Scenario-I (dominance) risk measure

Probability that an external attacker infers the dominant contribution
X1 to within +/- beta (Proposition 5 of the paper):
`mu_I(rho) = F_Z((1+beta)rho - 1) - F_Z((1-beta)rho - 1)`, with Z the
relative loss at dominance rho.

## Usage

``` r
assess_risk_I(rho, sigma_nu, sigma_eps, n, beta)
```

## Arguments

- rho:

  Dominance share X1/Y in (0,1\]. Recycled.

- sigma_nu, sigma_eps, n:

  Mechanism parameters. Recycled.

- beta:

  Accuracy threshold of the inference.

## Value

mu_I(rho), vectorised.

## Examples

``` r
assess_risk_I(rho = 0.85, sigma_nu = 0.3, sigma_eps = 0.03, n = 6, beta = 0.2)
#> [1] 0.5647026
```
