# Internal: worst case over rho of the scenario-I risk.
.risk_max_I <- function(sigma_nu, sigma_eps, n, beta, rho) {
  max(assess_risk_I(rho, sigma_nu, sigma_eps, n, beta))
}

#' Largest admissible shape parameter n
#'
#' Implements the step-2 calibration rule. The worst-case scenario-I risk
#' increases with `n`, while the information loss decreases with `n` at every
#' `rho < 1` and is unchanged at `rho = 1`. Both objectives are therefore
#' monotone and opposite in `n`: there is no interior optimum, and the best
#' choice is the upper edge of the admissible set,
#' `n_max = sup{n : max_rho mu_I <= tau}`. Because the risk is monotone, that
#' edge is found by root-finding rather than by a grid search.
#'
#' The rule holds whatever the dominance profile of the table: since utility
#' improves at every `rho`, no weighting by the actual distribution of `rho`
#' could favour a smaller `n`.
#'
#' Note this determines `n` *given* `sigma_nu`. Every point of the returned
#' frontier meets the ceiling exactly, so choosing among them is a pure utility
#' arbitrage -- larger `sigma_nu` costs more at `rho = 1` but spares cells of
#' intermediate dominance. The reported losses are there to settle it.
#'
#' @param params Optional `pm_params`; supplies `sigma_eps`, `beta` and `tau`.
#' @param sigma_nu Numeric vector of candidate values. Default
#'   `seq(0.05, 0.5, 0.05)`.
#' @param beta,tau Scenario-I threshold and ceiling. Default to the `dominance`
#'   policy of `params`.
#' @param sigma_eps Fixed differencing noise. Defaults to
#'   `params$mechanism$sigma_eps`.
#' @param margin Safety margin in [0,1): the effective ceiling is
#'   `tau * (1 - margin)`. `n_max` is a boundary solution with zero slack, so a
#'   small margin guards against later revisions of the policy. Default 0.
#' @param n_range Search interval for `n`. Default `c(1, 30)`.
#' @param integer If `TRUE`, round `n_max` down to an integer -- the only
#'   conservative rounding, the risk being increasing in `n`.
#' @param level Confidence level for the reported CI loss (default 0.95).
#' @param rho Grid used to locate the worst case. Default `seq(0.001, 1, 0.001)`.
#' @returns A `data.frame` with one row per `sigma_nu`: `n_max`,
#'   `risk_at_n_max`, and the information loss at `rho = 1` and at the dominance
#'   threshold `1 - beta`. `n_max` is `NA` when no `n` meets the ceiling (raise
#'   `sigma_nu`), and the upper end of `n_range` when the whole range qualifies.
#' @export
#' @examples
#' para <- pm_commit_diff(pm_params())
#' pm_suggest_n(para, sigma_nu = c(0.3, 0.4, 0.5))
pm_suggest_n <- function(params = NULL, sigma_nu = NULL,
                         beta = NULL, tau = NULL, sigma_eps = NULL,
                         margin = 0, n_range = c(1, 30), integer = FALSE,
                         level = 0.95, rho = NULL) {

  if (!is.null(params)) stopifnot(inherits(params, "pm_params"))

  if (is.null(sigma_eps) && !is.null(params)) sigma_eps <- params$mechanism$sigma_eps
  if (is.null(beta)     && !is.null(params)) beta      <- params$policy$dominance$beta
  if (is.null(tau)      && !is.null(params)) tau       <- params$policy$dominance$tau
  if (is.null(sigma_nu)) sigma_nu <- (1:10)/20
  if (is.null(rho))      rho      <- (1:1000)/1000

  assertthat::assert_that(
    !is.null(sigma_eps), !is.na(sigma_eps), !is.null(beta), !is.null(tau),
    !is.na(tau), length(beta) == 1L, length(tau) == 1L,
    margin >= 0, margin < 1, all(sigma_nu > 0),
    msg = paste0("Need a single beta and tau, a set sigma_eps (run ",
                 "pm_commit_diff() first), margin in [0;1) and sigma_nu > 0.")
  )

  target <- tau * (1 - margin)
  lo <- n_range[1]; hi <- n_range[2]

  res <- lapply(sigma_nu, function(sn) {
    r_lo <- .risk_max_I(sn, sigma_eps, lo, beta, rho)
    r_hi <- .risk_max_I(sn, sigma_eps, hi, beta, rho)

    if (r_lo > target) {                       # nothing admissible
      nmax <- NA_real_; rmax <- r_lo
    } else if (r_hi <= target) {               # whole range admissible
      nmax <- hi; rmax <- r_hi
    } else {
      nmax <- stats::uniroot( #solve f(x) = 0 where f(x) is max_risk - target (target =tau - margine)
        function(n) .risk_max_I(sn, sigma_eps, n, beta, rho) - target,
        interval = c(lo, hi), tol = 1e-6)$root
      if (integer) nmax <- floor(nmax)          # conservative rounding
      rmax <- .risk_max_I(sn, sigma_eps, nmax, beta, rho)
    }

    data.frame(
      sigma_nu      = sn,
      sigma_eps     = sigma_eps,
      beta          = beta,
      tau           = tau,
      target        = target,
      n_max         = nmax,
      risk_at_n_max = rmax,
      EZ_rho1       = 100 * assess_loss_expectation(1, sn, sigma_eps,
                                                    if (is.na(nmax)) 1 else nmax),
      EZ_rho_dom    = 100 * assess_loss_expectation(1 - beta, sn, sigma_eps,
                                                    if (is.na(nmax)) 1 else nmax),
      CI_rho1       = 100 * assess_loss_ci(1, sn, sigma_eps,
                                           if (is.na(nmax)) 1 else nmax, level),
      CI_rho_dom       = 100 * assess_loss_ci(1 - beta, sn, sigma_eps,
                                           if (is.na(nmax)) 1 else nmax, level)
    )
  })

  out <- do.call(rbind, res)
  rownames(out) <- NULL

  if (all(is.na(out$n_max)))
    warning("No admissible n for any sigma_nu: the ceiling cannot be met at ",
            "this noise level. Increase sigma_nu.", call. = FALSE)

  out
}
