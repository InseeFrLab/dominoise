# Scenario-II (p%-rule) risk measure

Probability that an insider contributing `X2` to the aggregate infers
the dominant contribution `X1` to within +/- beta, by subtracting their
own contribution from the disseminated total (Proposition 5 of the
paper):
`mu_II(rho, rho2) = F_Z((1+beta)rho + rho2 - 1) - F_Z((1-beta)rho + rho2 - 1)`,
with `Z` the relative loss at dominance `rho`.

## Usage

``` r
assess_risk_II(rho, rho2, sigma_nu, sigma_eps, n, beta)
```

## Arguments

- rho:

  Share of the largest contribution, X1/Y, in (0,1\]. Recycled.

- rho2:

  Share of the second contribution, X2/Y. Recycled.

- sigma_nu, sigma_eps, n:

  Mechanism parameters. Recycled.

- beta:

  Accuracy threshold of the inference.

## Value

mu_II(rho, rho2), vectorised.

## Details

The worst case (IIa) has the two largest contributors sharing the whole
cell (`rho + rho2 = 1`); the relaxed case (IIb) leaves a residual share
to the other contributors, typically `rho + rho2 = 0.95`.

## Examples

``` r
# worst case IIa at rho = 0.5
assess_risk_II(0.5, 0.5, sigma_nu = 0.4, sigma_eps = 0.031, n = 4, beta = 0.1)
#> [1] 0.7907045
```
