# Worst-case risk and loss range of a dominance calibration grid

Reduces the rho-resolved table to one row per parameter combination
`(sigma_nu, sigma_eps, n, beta)`. For each, reports where the scenario-I
risk peaks and its value, and the range of the information loss: the
minimum (smallest rho of the grid) and the maximum (rho = 1), in both
metrics – expectation E\|Z\| and upper CI bound. The loss is monotone
increasing in rho, so these are read at the extreme rho rows of each
group.

## Usage

``` r
# S3 method for class 'pm_calib_dominance'
summary(object, ...)
```

## Arguments

- object:

  A `pm_calib_dominance` table.

- ...:

  Ignored.

## Value

A `data.frame` of class `pm_calib_dominance_summary`, with columns
`sigma_nu`, `sigma_eps`, `n`, `beta`, `rho_at_max_risk`, `risk_max`,
`EZ_min`, `EZ_max`, `CI_min`, `CI_max` (losses in percent).

## Examples

``` r
grid <- pm_calib_dominance(sigma_nu = c(0.3, 0.4), n = c(3, 6), beta = 0.2)
summary(grid)
#>  sigma_nu sigma_eps n beta rho_at_max_risk risk_max EZ_min EZ_max CI_min CI_max
#>       0.3         0 3  0.2            0.92    0.543      0 23.937  0.000 58.799
#>       0.3         0 6  0.2            0.90    0.653      0 23.937  0.000 58.799
#>       0.4         0 3  0.2            0.88    0.443      0 31.915  0.001 78.399
#>       0.4         0 6  0.2            0.88    0.563      0 31.915  0.000 78.399
```
