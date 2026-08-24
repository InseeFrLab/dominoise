# Changelog

## dominoise (development version)

First working version of the package. The API is still unstable:
function names and arguments may change without deprecation until
version 1.0.0.

### Parameters

- [`pm_params()`](https://inseefrlab.github.io/dominoise/reference/pm_params.md)
  gathers every choice in a single object: the policy, organised by
  disclosure scenario (`dominance`, `prule`, `diff`), and the three
  mechanism parameters (`sigma_nu`, `sigma_eps`, `n`), filled in as
  calibration proceeds.

### Calibration — step 1, the differencing noise

- [`pm_calib_diff()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_diff.md)
  returns the theoretical grid of `sigma_eps` values meeting a given
  `(beta, tau)` couple, with the loss floor they imply.
- [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on that grid
  draws the risk-utility frontier.
- [`pm_commit_diff()`](https://inseefrlab.github.io/dominoise/reference/pm_commit_diff.md)
  records the decision and sets `sigma_eps`.

### Calibration — step 2, the dominance noise

- [`pm_calib_dominance()`](https://inseefrlab.github.io/dominoise/reference/pm_calib_dominance.md)
  returns, over a grid of dominance levels `rho`, the scenario-I risk
  and the information loss for each candidate `(sigma_nu, n)`.
- [`summary()`](https://rdrr.io/r/base/summary.html) reduces that grid
  to the worst-case risk and the loss range of every parameter
  combination.
- [`pm_suggest_n()`](https://inseefrlab.github.io/dominoise/reference/pm_suggest_n.md)
  solves for the largest `n` meeting the risk ceiling — the calibration
  rule of step 2 — with an optional safety margin.
- [`pm_commit_dominance()`](https://inseefrlab.github.io/dominoise/reference/pm_commit_dominance.md)
  records `sigma_nu` and `n`, and reports the resulting trade-off.

### Figures

- [`pm_plot_risk_profile()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_risk_profile.md),
  [`pm_plot_risk_max()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_risk_max.md)
  and
  [`pm_plot_tradeoff()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_tradeoff.md)
  reproduce the calibration figures of the paper. The first two accept
  any scenario; the third is specific to the risk metric selected.
- [`pm_plot_impact()`](https://inseefrlab.github.io/dominoise/reference/pm_plot_impact.md)
  superposes the empirical and theoretical losses depending on `rho`.

### Applying the mechanism

- [`pm_perturb()`](https://inseefrlab.github.io/dominoise/reference/pm_perturb.md)
  applies `Y' = Y (1 + rho^n nu + eps)` to an aggregated table and
  returns it with `rho`, the derived keys and the perturbed total, plus
  a `pm_meta` attribute recording the full configuration.
- [`pm_draws()`](https://inseefrlab.github.io/dominoise/reference/pm_draws.md)
  derives the two Gaussian draws from a cell key by SHA-512 hashing and
  quantile inversion, so that perturbations are reproducible over time.

### Metrics

- [`assess_loss_expectation()`](https://inseefrlab.github.io/dominoise/reference/assess_loss_expectation.md)
  and
  [`assess_loss_ci()`](https://inseefrlab.github.io/dominoise/reference/assess_loss_ci.md)
  give the a-priori information loss conditional on dominance.
- [`assess_risk_I()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_I.md)
  and
  [`assess_risk_II()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_II.md)
  give the a-priori risk measures for the external and internal
  inference scenarios.
- [`assess_risk_diff()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_diff.md)
  gives an a-priori upper bound of the risk measure for the differencing
  scenario.
- [`assess_utility_empirical()`](https://inseefrlab.github.io/dominoise/reference/assess_utility_empirical.md)
  and
  [`assess_risk_empirical()`](https://inseefrlab.github.io/dominoise/reference/assess_risk_empirical.md)
  measure what was actually achieved on the perturbed table, alongside
  the theoretical values predicted for the same cells.
