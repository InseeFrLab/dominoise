# Package index

## Parameters

The single object gathering every policy and mechanism choice, filled in
as calibration proceeds.

- [`pm_params()`](https://inseefrlab.github.io/dominoise/reference/pm_params.md)
  : Create the perturbation-parameter object containing all the
  parameters of the noise.

## Calibration — step 1, differencing noise

Choosing sigma_eps from the differencing risk ceiling. This parameter
also sets the loss floor borne by every cell.

- [`pm_calib_diff()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_diff.md)
  : Calibration of the differencing noise (sigma_epsilon)
- [`pm_sigma_eps()`](https://inseefrlab.github.io/dominoise/reference/pm_sigma_eps.md)
  : Smallest sigma_eps guaranteeing the differencing-risk ceiling
- [`pm_commit_diff()`](https://inseefrlab.github.io/dominoise/reference/pm_commit_diff.md)
  : Commit the differencing decision into the parameter object

## Calibration — step 2, dominance noise

Choosing sigma_nu and n from the scenario-I risk ceiling, keeping the
largest admissible n.

- [`pm_calib_dominance()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_dominance.md)
  : Calibration of the dominance noise (sigma_nu and n)
- [`pm_suggest_n()`](https://inseefrlab.github.io/dominoise/reference/pm_suggest_n.md)
  : Largest admissible shape parameter n
- [`pm_commit_dominance()`](https://inseefrlab.github.io/dominoise/reference/pm_commit_dominance.md)
  : Commit the dominance decision (sigma_nu and n) into the parameter
  object

## Calibration figures

The risk and risk-utility figures of the paper.

- [`pm_plot_risk_max()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_risk_max.md)
  : Worst-case risk as a function of sigma_nu
- [`pm_plot_risk_profile()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_risk_profile.md)
  : Risk profile as a function of dominance
- [`pm_plot_tradeoff()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_tradeoff.md)
  : Risk-utility trade-off map

## Applying the mechanism

Deriving the Gaussian draws from the cell keys, and perturbing an
aggregated table.

- [`pm_draws()`](https://inseefrlab.github.io/dominoise/reference/pm_draws.md)
  : Derive the two Gaussian draws from a cell key
- [`pm_perturb()`](https://inseefrlab.github.io/dominoise/reference/pm_perturb.md)
  : Perturb an aggregated table

## A-priori risk and utility

Closed-form metrics, conditional on the dominance level, computed from
the parameters alone.

- [`assess_loss_expectation()`](https://inseefrlab.github.io/dominoise/reference/assess_loss_expectation.md)
  : Conditional expectation of the absolute relative loss \|Z\|
- [`assess_loss_ci()`](https://inseefrlab.github.io/dominoise/reference/assess_loss_ci.md)
  : Confidence-interval bound of the relative loss Z
- [`assess_risk_I()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_I.md)
  : Scenario-I (dominance) risk measure
- [`assess_risk_II()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_II.md)
  : Scenario-II (p%-rule) risk measure
- [`assess_risk_diff()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_diff.md)
  : Compute the upper bound of the differencing risk, following the
  proposition 7 of the paper.

## Ex-post assessment

Risk and utility measured on the perturbed table itself.

- [`assess_utility_empirical()`](https://inseefrlab.github.io/dominoise/reference/assess_utility_empirical.md)
  : Observed information loss
- [`assess_risk_empirical()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_empirical.md)
  : Observed disclosure risk

## Methods and utilities

S3 methods for printing, summarising and plotting the objects returned
by the calibration functions. Not called directly.

- [`summary(`*`<pm_calib_dominance>`*`)`](https://inseefrlab.github.io/dominoise/reference/summary.pm_calib_dominance.md)
  : Worst-case risk and loss range of a dominance calibration grid
- [`plot(`*`<pm_calib_diff>`*`)`](https://inseefrlab.github.io/dominoise/reference/plot.pm_calib_diff.md)
  : Plot method for a differencing calibration grid
- [`plot(`*`<pm_calib_dominance>`*`)`](https://inseefrlab.github.io/dominoise/reference/plot.pm_calib_dominance.md)
  : Plot method for a dominance calibration grid
