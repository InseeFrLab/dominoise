# Observed disclosure risk

For each cell, evaluates whether the attack of a given scenario would in
fact have succeeded on the realised perturbation – scenario I:
`|Y' - X1| / X1 < beta`; scenario II: `|(Y' - X2) - X1| / X1 < beta` –
and compares the observed success rate with the theoretical probability
`mu(rho)` averaged over the table. The two should agree: the realised
rate is one draw from the probability the mechanism guarantees.

## Usage

``` r
assess_risk_empirical(x, scenario = c("I", "II"), beta = NULL, by = NULL)
```

## Arguments

- x:

  A table returned by
  [`pm_perturb()`](https://inseefrlab.github.io/dominoise/reference/pm_perturb.md).

- scenario:

  `"I"` (default) or `"II"`.

- beta:

  Accuracy threshold. Defaults to the matching policy of the parameter
  object.

- by:

  Optional column name(s) to break the summary down by.

## Value

A `data.frame` with the number of cells, the observed success rate (in
percent), the mean theoretical risk, and the maximum theoretical risk.

## Details

Scenario II requires the `x2` column to have been declared in
[`pm_perturb()`](https://inseefrlab.github.io/dominoise/reference/pm_perturb.md),
which adds the `rho2` share the theoretical measure needs. The
differencing scenario is not assessed here: it bears on pairs of cells,
not on single cells, and is controlled a priori by the bound of
Proposition 7.
