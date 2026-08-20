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
`sigma_nu`, `sigma_eps`, `n`, `beta`, `rho_at_max`, `risk_max`,
`EZ_min`, `EZ_max`, `CI_min`, `CI_max` (losses in percent).
