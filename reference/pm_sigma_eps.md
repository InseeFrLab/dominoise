# Smallest sigma_eps guaranteeing the differencing-risk ceiling

Closed-form inversion of the worst-case upper bound of the differencing
risk (Proposition 7 of the paper)

## Usage

``` r
pm_sigma_eps(beta, tau)
```

## Arguments

- beta, tau:

  Numeric. Accuracy threshold and risk ceiling.

## Value

sigma_eps, vectorised over `beta`/`tau`.
