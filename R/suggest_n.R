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
  if (is.null(sigma_nu)) sigma_nu <- seq(0.05, 0.5, by = 0.05)
  if (is.null(rho))      rho      <- seq(0.001, 1, by = 0.001)

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


#' Worst-case risk against a mechanism parameter
#'
#' Reduces a calibration table to the worst case over `rho` and plots it against
#' one of the two mechanism parameters.
#'
#' With `x_axis = "sigma_nu"` this is the middle panel of Figure 3: the risk
#' decreases with `sigma_nu`, one curve per `n`.
#'
#' With `x_axis = "n"` it is the view that accompanies [pm_suggest_n()]: the risk
#' increases monotonically with `n`, one curve per `sigma_nu`. Each crossing of
#' the ceiling `tau` is the `n_max` of its `sigma_nu` -- the very root that
#' [pm_suggest_n()] solves for. Set `mark_frontier = TRUE` to overlay those
#' points, computed by the same function so the plot and the table always agree.
#'
#' @param x A calibration table (e.g. from [pm_calib_dominance()]).
#' @param x_axis Parameter on the x-axis: `"sigma_nu"` (default) or `"n"`.
#' @param sigma_nu,n,beta,sigma_eps,scenario Optional values to keep.
#' @param tau Risk ceiling, drawn as a dashed line. Defaults to `thresholds`.
#' @param mark_frontier If `TRUE` and `x_axis = "n"`, mark the largest
#'   admissible `n` of each `sigma_nu` with a point. Requires a single `tau`.
#' @param marks Values of the x-axis parameter highlighted with a point;
#'   `NULL` for none.
#' @param thresholds Risk levels drawn as dashed horizontal lines.
#' @returns A `ggplot` object.
#' @export
#' @examples
#' grid <- pm_calib_dominance(sigma_eps = 0.031, beta = 0.2,
#'                            sigma_nu = c(0.3, 0.4, 0.5), n = seq(1, 12, 0.2))
#' pm_plot_risk_max(grid, x_axis = "n", tau = 0.5)
pm_plot_risk_max <- function(x, x_axis = c("sigma_nu", "n"),
                             sigma_nu = NULL, n = NULL, beta = NULL,
                             sigma_eps = NULL, scenario = NULL,
                             tau = NULL, mark_frontier = TRUE,
                             marks = NULL, thresholds = c(0.5, 0.8)) {

  x_axis <- match.arg(x_axis)
  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required.", call. = FALSE)

  d <- .pm_plot_data(x, sigma_nu, n, beta, sigma_eps, scenario)
  d <- .pm_require_single(d, "beta", "pm_plot_risk_max")
  d <- .pm_require_single(d, "sigma_eps", "pm_plot_risk_max")

  # worst case over rho, per parameter combination
  grp <- c("sigma_nu", "sigma_eps", "n", "beta",
           if ("scenario" %in% names(d)) "scenario")
  sm <- d |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grp))) |>
    dplyr::summarise(risk_max = max(.data$risk), .groups = "drop")

  # swap the roles of the two parameters
  if (x_axis == "n") {
    sm$xvar  <- sm$n
    sm$grp_f <- factor(sm$sigma_nu, levels = sort(unique(sm$sigma_nu)))
    xlab <- "n"; collab <- expression(sigma[nu])
  } else {
    sm$xvar  <- sm$sigma_nu
    sm$grp_f <- factor(sm$n, levels = sort(unique(sm$n)))
    xlab <- expression(sigma[nu]); collab <- "n"
  }

  lines <- if (is.null(tau)) thresholds else unique(c(thresholds, tau))

  p <- ggplot2::ggplot(sm, ggplot2::aes(x = .data$xvar, y = .data$risk_max,
                                        colour = .data$grp_f))
  p <- .pm_thresholds(p, lines)
  p <- p + ggplot2::geom_line(linewidth = 0.9)

  if (!is.null(marks) && length(marks)) {
    mk <- sm[sm$xvar %in% marks, , drop = FALSE]
    if (nrow(mk)) p <- p + ggplot2::geom_point(data = mk, size = 1.6)
  }

  # overlay the frontier: largest admissible n per sigma_nu
  if (isTRUE(mark_frontier)) {
    if (x_axis != "n")
      warning("mark_frontier applies to x_axis = 'n' only; ignored.",
              call. = FALSE)
    else if (is.null(tau) || length(tau) != 1L)
      warning("mark_frontier needs a single 'tau'; ignored.", call. = FALSE)
    else {
      fr <- pm_suggest_n(sigma_nu  = sort(unique(sm$sigma_nu)),
                         beta      = sm$beta[1],
                         tau       = tau,
                         sigma_eps = sm$sigma_eps[1],
                         n_range   = range(sm$n))
      fr <- fr[!is.na(fr$n_max), , drop = FALSE]
      if (nrow(fr)) {
        fr$grp_f <- factor(fr$sigma_nu, levels = levels(sm$grp_f))
        p <- p + ggplot2::geom_point(
          data = fr,
          ggplot2::aes(x = .data$n_max, y = .data$risk_at_n_max,
                       colour = .data$grp_f),
          shape = 21, fill = "white", size = 2.6, stroke = 1)
      }
    }
  }

  if ("scenario" %in% names(sm))
    p <- p + ggplot2::facet_wrap(~ scenario)

  p +
    ggplot2::scale_colour_viridis_d(name = collab, end = 0.85) +
    ggplot2::scale_y_continuous(limits = c(0, 1.01), expand = c(0, 0),
                                breaks = c(seq(0, 1, 0.25), 0.8)) +
    ggplot2::labs(x = xlab,
                  y = expression(paste("Risk (worst case in ", rho, ")")),
                  subtitle = sprintf("beta = %g, sigma_eps = %g",
                                     sm$beta[1], sm$sigma_eps[1])) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "bottom",
                   legend.title.position = "top")
}
