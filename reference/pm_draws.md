# Derive the two Gaussian draws from a cell key

Implements Definitions 6-7 of the paper. From the cell key `CK`, the
name of the indicator and the aggregation operation, two distinct
strings are built – one per draw – and hashed with SHA-512. Each digest
is mapped to a uniform draw in \]0;1\[, then turned into a Gaussian draw
by quantile inversion: `nu` from N(0, sigma_nu^2) and `eps` from N(0,
sigma_eps^2).

## Usage

``` r
pm_draws(ck, params, indicator, operation = "sum", key_digits = 9L)
```

## Arguments

- ck:

  Numeric vector of cell keys in \[0;1\].

- params:

  A fully calibrated `pm_params` object.

- indicator:

  Name of the indicator the aggregate is computed from (e.g.
  `"turnover"`). Enters the hashed string.

- operation:

  Name of the aggregation (default `"sum"`). Enters the hashed string,
  so that several statistics on the same indicator get independent
  draws.

- key_digits:

  Number of decimals used to turn the key into a string. Fixed for
  reproducibility; changing it changes every draw.

## Value

A `data.frame` with columns `ck_nu`, `ck_eps`, `nu`, `eps`.

## Details

Determinism, avalanche effect and uniformity of SHA-512 (Proposition 8)
ensure that the same cell always receives the same perturbation, while
draws remain uncorrelated across indicators and between `nu` and `eps`.

## Examples

``` r
para <- pm_commit_dominance(pm_commit_diff(pm_params()), sigma_nu = 0.4, n = 4)
#> Differencing step committed: beta = 0.05, tau = 0.95  ->  sigma_eps = 0.0255
#>   loss floor at rho -> 0:  E|Z| = 2.04%,  upper 95% CI = 5.00%
#> Dominance step committed: sigma_nu = 0.4, n = 4 (beta = 0.2, sigma_eps = 0.0255107)
#>   worst-case scenario-I risk: 0.482, reached at rho = 0.875
#>   information loss E|Z| : 2.04% (rho -> 0) to 31.98% (rho = 1)
#>   information loss CI95%: 5.00% (rho -> 0) to 78.56% (rho = 1)
#>   ceiling tau = 0.9: met (margin 0.418).
pm_draws(c(0.12, 0.87), para, indicator = "turnover")
#>       ck_nu    ck_eps         nu         eps
#> 1 0.3001429 0.0560337 -0.2095958 -0.04053567
#> 2 0.6236417 0.2439149  0.1260237 -0.01769840
```
