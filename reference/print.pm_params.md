# Method to print pm_params object

Method to print pm_params object

## Usage

``` r
# S3 method for class 'pm_params'
print(x, ...)
```

## Arguments

- x:

  pm_params object

- ...:

  Ignored

## Value

pm_params object x

## Examples

``` r
para <- pm_params()
para
#> <pm_params>
#>   policy
#>     dominance : beta = 0.2, tau = 0.9
#>     p%-rule   : beta = 0.1, tau = 0.9, s = 0.95
#>     diff      : beta = 0.05, tau = 0.95
#>   parameters of the mechanism
#>     sigma_nu  = <not set>
#>     sigma_eps = <not set>
#>     n         = <not set>
```
