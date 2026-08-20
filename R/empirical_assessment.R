# =============================================================================
# Ex-post assessment: risk and utility measured on the perturbed table itself.
# Complements the a-priori, rho-conditional metrics of utility_metrics.R.
# =============================================================================

.pm_meta <- function(x) {
  m <- attr(x, "pm_meta")
  if (is.null(m))
    stop("This table has no 'pm_meta' attribute: was it produced by pm_perturb()?",
         call. = FALSE)
  m
}

#' Observed information loss
#'
#' Measures the perturbation actually undergone by the table, and compares it
#' with the theoretical expectation of Proposition 3 evaluated at each cell's
#' own dominance. A close match is the natural consistency check: the mechanism
#' is analytical, so the realised loss should track the predicted one.
#'
#' @param x A table returned by [pm_perturb()].
#' @param by Optional column name(s) to break the summary down by (e.g. a
#'   publication stratum, or a dominance band built beforehand).
#' @param thresholds Relative deviations (in percent) whose exceedance rate is
#'   reported.
#' @returns A `data.frame`: number of cells, mean and median absolute relative
#'   deviation, quantiles, maximum, relative RMSE, exceedance rates, and the
#'   theoretical mean absolute loss averaged over the observed dominance.
#' @export
assess_utility_empirical <- function(x, by = NULL, thresholds = c(5, 10, 20)) {

  m <- .pm_meta(x)
  d <- as.data.frame(x)
  Y  <- d[[m$total]]
  Yp <- d[[m$perturbed]]

  ok <- !is.na(Y) & Y > 0 & !is.na(Yp)
  d  <- d[ok, , drop = FALSE]
  dev <- 100 * (d[[m$perturbed]] - d[[m$total]]) / d[[m$total]]
  d$.dev <- dev

  p <- m$params$mechanism
  d$.theo <- 100 * assess_loss_expectation(d$rho, p$sigma_nu, p$sigma_eps, p$n)

  one <- function(g) {
    a <- abs(g$.dev)
    out <- data.frame(
      n_cells      = nrow(g),
      mean_abs_dev = mean(a),
      median_abs_dev = stats::median(a),
      q90_abs_dev  = stats::quantile(a, 0.90, names = FALSE),
      max_abs_dev  = max(a),
      rmse_rel     = sqrt(mean(g$.dev^2)),
      theo_mean_abs = mean(g$.theo)
    )
    for (t in thresholds)
      out[[paste0("pct_above_", t)]] <- 100 * mean(a > t)
    out
  }

  if (is.null(by)) {
    res <- one(d)
  } else {
    parts <- split(d, interaction(d[by], drop = TRUE))
    res <- do.call(rbind, lapply(names(parts), function(k) {
      cbind(data.frame(group = k), one(parts[[k]]))
    }))
  }
  rownames(res) <- NULL
  res
}

#' Observed disclosure risk
#'
#' For each cell, evaluates whether the attack of a given scenario would in fact
#' have succeeded on the realised perturbation -- scenario I:
#' `|Y' - X1| / X1 < beta`; scenario II: `|(Y' - X2) - X1| / X1 < beta` -- and
#' compares the observed success rate with the theoretical probability
#' `mu(rho)` averaged over the table. The two should agree: the realised rate is
#' one draw from the probability the mechanism guarantees.
#'
#' Scenario II requires the `x2` column to have been declared in [pm_perturb()],
#' which adds the `rho2` share the theoretical measure needs.
#' The differencing scenario is not assessed here: it bears on pairs of cells,
#' not on single cells, and is controlled a priori by the bound of Proposition 7.
#'
#' @param x A table returned by [pm_perturb()].
#' @param scenario `"I"` (default) or `"II"`.
#' @param beta Accuracy threshold. Defaults to the matching policy of the
#'   parameter object.
#' @param by Optional column name(s) to break the summary down by.
#' @returns A `data.frame` with the number of cells, the observed success rate
#'   (in percent), the mean theoretical risk, and the maximum theoretical risk.
#' @export
assess_risk_empirical <- function(x, scenario = c("I", "II"), beta = NULL,
                                  by = NULL) {

  scenario <- match.arg(scenario)
  m <- .pm_meta(x)
  d <- as.data.frame(x)
  p <- m$params$mechanism

  if (is.null(beta))
    beta <- if (scenario == "I") m$params$policy$dominance$beta
  else m$params$policy$prule$beta

  Y  <- d[[m$total]]
  ok <- !is.na(Y) & Y > 0 & !is.na(d[[m$perturbed]])
  d  <- d[ok, , drop = FALSE]

  X1 <- d[[m$x1]]
  Yp <- d[[m$perturbed]]

  if (scenario == "I") {
    est <- Yp
    d$.theo <- assess_risk_I(d$rho, p$sigma_nu, p$sigma_eps, p$n, beta)
  } else {
    if (is.null(m$x2))
      stop("Scenario II needs the 'x2' column: declare it in pm_perturb().",
           call. = FALSE)
    est <- Yp - d[[m$x2]]
    d$.theo <- assess_risk_II(d$rho, d$rho2, p$sigma_nu, p$sigma_eps, p$n, beta)
  }
  d$.hit <- abs(est - X1) / X1 < beta

  one <- function(g) data.frame(
    scenario      = scenario,
    beta          = beta,
    n_cells       = nrow(g),
    observed_pct  = 100 * mean(g$.hit),
    theo_mean     = mean(g$.theo),
    theo_max      = if (all(is.na(g$.theo))) NA_real_ else max(g$.theo, na.rm = TRUE)
  )

  if (is.null(by)) {
    res <- one(d)
  } else {
    parts <- split(d, interaction(d[by], drop = TRUE))
    res <- do.call(rbind, lapply(names(parts), function(k) {
      cbind(data.frame(group = k), one(parts[[k]]))
    }))
  }
  rownames(res) <- NULL
  res
}
