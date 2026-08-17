# =============================================================================
#
# Calibration step 2 (Scenario I) : Set sigma_nu the amount of noise
# to inject to protect dominance inferences and n the shape of
# the curve of the noise.
#
# =============================================================================


#' Calibration of the dominance noise (sigma_nu and n)
#'
#' Theoretical, data-free. For every candidate `(sigma_nu, n, beta, sigma_eps)`,
#' evaluates the scenario-I risk over an internal grid of dominance levels
#' `rho`, keeps its worst case (max over rho), and reports the maximum
#' information loss (reached at rho = 1, hence set by `sigma_nu` alone). The
#' returned table is the decision surface of step 2: feed it to [plot()] for the
#' risk heat-map, to [pm_suggest_n()] for the largest admissible `n`, then lock
#' the choice with [pm_commit_dominance()].
#'
#' Like [pm_calib_diff()], calling it with everything at `NULL` returns a
#' default exploration grid.
#'
#' @param params Optional `pm_params`. When supplied, `sigma_eps` and `beta`
#'   default to its values.
#' @param sigma_nu,n Numeric vectors of candidate values. Default to
#'   `seq(0.05, 0.5, 0.05)` and `seq(3, 12, 0.5)`.
#' @param beta Accuracy threshold(s) of scenario I. Default to the `dominance`
#'   policy of `params`, or to `c(0.05, 0.1, 0.15, 0.2, 0.25)` (as in the
#'   differencing step).
#' @param sigma_eps Fixed differencing noise. Default to
#'   `params$mechanism$sigma_eps`, or to `c(0, 0.03, 0.05)` (a few illustrative
#'   values, including the noiseless case) when no `params` is given.
#' @param level Confidence level for the CI loss metric (default 0.95).
#' @param rho Internal grid of dominance levels used to locate the worst case.
#'   Default `seq(0, 1, 0.02)`.
#' @returns A `data.frame` of class `pm_calib_dominance`, one row per
#'   `(sigma_nu, n, beta, sigma_eps)`, with columns `risk_max`, `rho_at_max`,
#'   `EZ_max`, `CI_max` (the last two in percent).
#' @export
#' @examples
#' # default exploration
#' pm_calib_dominance()
#'
#' # at a committed sigma_eps
#' para <- pm_commit_diff(pm_params())
#' grid <- pm_calib_dominance(para)
pm_calib_dominance <- function(
    params = NULL,
    sigma_nu = NULL, n = NULL, beta = NULL,
    sigma_eps = NULL, level = 0.95, rho = NULL
) {

  if (!is.null(params)) stopifnot(inherits(params, "pm_params"))

  if (is.null(sigma_eps)) {
    if (!is.null(params) && !is.na(params$mechanism$sigma_eps)) {
      sigma_eps <- params$mechanism$sigma_eps
    } else {
      sigma_eps <- c(0, 0.03, 0.05)
    }
  }
  if (is.null(beta)) {
    if (!is.null(params)) {
      beta <- params$policy$dominance$beta
    } else {
      beta <- c(0.05, 0.1, 0.15, 0.2, 0.25)
    }
  }
  if (is.null(sigma_nu)) sigma_nu <- seq(0.05, 0.5, by = 0.05)
  if (is.null(n))        n        <- seq(3, 12, by = 0.5)
  if (is.null(rho))      rho      <- seq(0, 1, by = 0.02)[-1]

  assertthat::assert_that(
    all(sigma_nu > 0), all(n > 0), all(sigma_eps >= 0),
    all(beta > 0 & beta < 1), all(rho > 0 & rho <= 1),
    msg = "Expected: sigma_nu, n > 0; sigma_eps >= 0; beta in (0;1); rho in (0;1]."
  )

  combos <- expand.grid(
    rho = rho,
    sigma_nu = sigma_nu,
    sigma_eps = sigma_eps,
    n = n,
    beta = beta,
    KEEP.OUT.ATTRS = FALSE
    )

  risks <- purrr::pmap_dbl(combos, assess_risk_I)
  loss_expect <- purrr::pmap_dbl(combos[, c("rho","sigma_nu","sigma_eps","n")], assess_loss_expectation)
  loss_ci <- purrr::pmap_dbl(combos[, c("rho","sigma_nu","sigma_eps","n")], assess_loss_ci)

  out <- combos
  out$risk <- risks
  out$EZ <- loss_expect *100
  out$CI <- loss_ci *100

  out <- out[order(out$sigma_eps, out$beta, out$sigma_nu, out$n, out$rho), ]

  rownames(out) <- NULL
  attr(out, "level") <- level
  class(out) <- c("pm_calib_dominance", "data.frame")
  out
}
