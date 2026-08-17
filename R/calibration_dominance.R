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
#'   `params$mechanism$sigma_eps`, or `0` when no `params` is given.
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
      sigma_eps <- 0
    }
  }
  if (is.null(beta)) {
    if (!is.null(params)) {
      beta <- params$policy$dominance$beta
    } else {
      beta <- c(0.1, 0.2)
    }
  }
  if (is.null(sigma_nu)) sigma_nu <- seq(0.1, 0.5, by = 0.1)
  if (is.null(n))        n        <- seq(3, 12, by = 3)
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

#' Worst-case risk and loss range of a dominance calibration grid
#'
#' Reduces the rho-resolved table to one row per parameter combination
#' `(sigma_nu, sigma_eps, n, beta)`. For each, reports where the scenario-I risk
#' peaks and its value, and the range of the information loss: the minimum
#' (smallest rho of the grid) and the maximum (rho = 1), in both metrics --
#' expectation E|Z| and upper CI bound. The loss is monotone increasing in rho,
#' so these are read at the extreme rho rows of each group.
#'
#' @param object A `pm_calib_dominance` table.
#' @param ... Ignored.
#' @returns A `data.frame` of class `pm_calib_dominance_summary`, with columns
#'   `sigma_nu`, `sigma_eps`, `n`, `beta`, `rho_at_max`, `risk_max`,
#'   `EZ_min`, `EZ_max`, `CI_min`, `CI_max` (losses in percent).
#' @export
#' @examples
#' grid <- pm_calib_dominance()
#' summary.pm_calib_dominance(grid)
summary.pm_calib_dominance <- function(object, ...) {
  d <- as.data.frame(object)

  sm <- d |>
    dplyr::group_by(sigma_nu, sigma_eps, n, beta) |>
    dplyr::summarise(
      rho_at_max_risk = rho[risk == max(risk)][1],
      risk_max = max(risk),
      EZ_min = min(EZ),
      EZ_max = max(EZ),
      CI_min = min(CI),
      CI_max = max(CI),
      .groups = "drop"
    )

  rownames(sm) <- NULL
  attr(sm, "level") <- attr(object, "level")
  class(sm) <- c("pm_calib_dominance_summary", "data.frame")
  sm
}

#' @export
print.pm_calib_dominance_summary <- function(x, digits = 3, ...) {
  df  <- as.data.frame(x)
  num <- vapply(df, is.numeric, logical(1))
  df[num] <- lapply(df[num], round, digits)
  print(df, row.names = FALSE)
  invisible(x)
}

#' Print method for a dominance calibration grid
#'
#' Shows the grid's extent (rho and the parameter axes) and the worst-case
#' risk / loss-range digest produced by [summary()].
#'
#' @param x A `pm_calib_dominance` table.
#' @param rows Number of summary rows to display (default 8).
#' @param ... Ignored.
#' @returns `x`, invisibly.
#' @export
print.pm_calib_dominance <- function(x, rows = 8, ...) {
  rng <- function(v) sprintf("%d values in [%g, %g]",
                             length(unique(v)), min(v), max(v))
  lst <- function(v) paste(sort(unique(v)), collapse = ", ")

  cat(sprintf("<pm_calib_dominance>  %d rows (rho-resolved)\n", nrow(x)))
  cat(sprintf("  rho      : %s\n", rng(x$rho)))
  cat(sprintf("  sigma_nu : %s\n", rng(x$sigma_nu)))
  cat(sprintf("  n        : %s\n", rng(x$n)))
  cat(sprintf("  beta     : %s\n", lst(x$beta)))
  cat(sprintf("  sigma_eps: %s\n", lst(x$sigma_eps)))
  cat(sprintf("  CI level : %.0f%%\n", 100 * attr(x, "level")))

  sm <- summary(x)
  n_combo <- nrow(sm)
  cat(sprintf("\n  worst-case risk & loss range per combination (%d total):\n",
              n_combo))
  print(utils::head(sm, rows))
  if (n_combo > rows)
    cat(sprintf("  ... %d more; call summary() for the full digest.\n",
                n_combo - rows))

  invisible(x)
}
