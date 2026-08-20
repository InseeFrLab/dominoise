# =============================================================================
# Plots for the calibration steps.
#
# All three work on a long-format calibration table with columns
#   rho, sigma_nu, sigma_eps, n, beta, risk, EZ, CI
# plus an OPTIONAL `scenario` column. When `scenario` is present the panels are
# split by it, so the same functions serve scenarios I, IIa and IIb as soon as
# a p%-rule calibration produces a table of the same shape.
#
# Reuses summary.pm_calib_dominance() for the worst-case plot.
# =============================================================================

# ---- internal: filter, validate, and prepare a calibration table ------------

.pm_plot_data <- function(x, sigma_nu = NULL, n = NULL, beta = NULL,
                          sigma_eps = NULL, scenario = NULL) {

  d <- as.data.frame(x)
  needed <- c("rho", "sigma_nu", "sigma_eps", "n", "beta", "risk")
  missing <- setdiff(needed, names(d))
  if (length(missing))
    stop("Calibration table is missing column(s): ",
         paste(missing, collapse = ", "), call. = FALSE)

  keep <- function(d, col, vals) {
    if (is.null(vals)) return(d)
    out <- d[d[[col]] %in% vals, , drop = FALSE]
    if (!nrow(out))
      stop(sprintf("No row left after filtering %s on the requested value(s).",
                   col), call. = FALSE)
    out
  }
  d <- keep(d, "sigma_nu",  sigma_nu)
  d <- keep(d, "n",         n)
  d <- keep(d, "beta",      beta)
  d <- keep(d, "sigma_eps", sigma_eps)
  if (!is.null(scenario) && "scenario" %in% names(d))
    d <- keep(d, "scenario", scenario)

  d
}

# Add dashed risk thresholds, shared by the risk plots.
.pm_thresholds <- function(p, thresholds) {
  if (is.null(thresholds) || !length(thresholds)) return(p)
  p + ggplot2::geom_hline(yintercept = thresholds, linetype = "dashed",
                          colour = "grey60", linewidth = 0.5)
}

# A single value is expected on these axes; warn and keep the first otherwise.
.pm_require_single <- function(d, col, what) {
  vals <- unique(d[[col]])
  if (length(vals) > 1L) {
    warning(sprintf("%s: %s takes %d values; keeping %s = %s. Use the '%s' ",
                    what, col, length(vals), col, format(vals[1]), col),
            "argument to choose another.", call. = FALSE)
    d <- d[d[[col]] == vals[1], , drop = FALSE]
  }
  d
}

# ---- Figure 2 of the paper: risk profile against dominance -----------------

#' Risk profile as a function of dominance
#'
#' Reproduces Figure 2 of the paper, generalised: the disclosure risk against
#' the dominance level `rho`, one curve per shape parameter `n`, panels split by
#' `sigma_nu` (and by `scenario` when the table carries several).
#'
#' @param x A calibration table (e.g. from [pm_calib_dominance()]).
#' @param sigma_nu,n,beta,sigma_eps,scenario Optional values to keep; `NULL`
#'   keeps everything present in the table. Filtering is usually needed on
#'   `beta` and `sigma_eps` to keep the panel grid readable.
#' @param thresholds Risk levels drawn as dashed horizontal lines.
#' @returns A `ggplot` object.
#' @export
#' @examples
#' grid <- pm_calib_dominance(beta = c(0.1,0.2))
#' pm_plot_risk_profile(grid, sigma_nu = c(0.1, 0.2, 0.4, 0.5), beta = 0.2)
pm_plot_risk_profile <- function(x,
                                 sigma_nu = NULL, n = NULL, beta = NULL,
                                 sigma_eps = NULL, scenario = NULL,
                                 thresholds = c(0.5, 0.8)) {

  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required.", call. = FALSE)

  d <- .pm_plot_data(x, sigma_nu, n, beta, sigma_eps, scenario)
  d <- .pm_require_single(d, "beta", "pm_plot_risk_profile")
  d <- .pm_require_single(d, "sigma_eps", "pm_plot_risk_profile")
  d$n_f <- factor(d$n, levels = sort(unique(d$n)))

  p <- ggplot2::ggplot(d, ggplot2::aes(x = .data$rho, y = .data$risk,
                                       colour = .data$n_f))
  p <- .pm_thresholds(p, thresholds)
  p <- p + ggplot2::geom_line(linewidth = 0.9)

  p <- p +
    ggplot2::facet_wrap(~ sigma_nu, labeller = ggplot2::labeller(
      sigma_nu = function(v) paste0("sigma_nu = ", v)))

  p +
    ggplot2::scale_colour_viridis_d(name = "n", end = 0.85) +
    ggplot2::scale_x_continuous(limits = c(0, 1.01), expand = c(0, 0),
                                breaks = seq(0, 1, 0.25)) +
    ggplot2::scale_y_continuous(limits = c(-0.005, 1.01), expand = c(0, 0),
                                breaks = seq(0, 1, 0.2)) +
    ggplot2::labs(x = expression(rho), y = "Risk",
                  subtitle = sprintf("beta = %g, sigma_eps = %g",
                                     d$beta[1], d$sigma_eps[1])) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "bottom",
                   legend.title.position = "top")
}

# ---- Figure 3 of the paper : worst-case risk against sigma_nu ---------------

#' Worst-case risk as a function of sigma_nu
#'
#' Reproduces the middle panel of Figure 3, generalised: the worst case over
#' `rho` of the disclosure risk against `sigma_nu`, one curve per `n`, at a
#' fixed `sigma_eps`. Panels split by `scenario` when several are present.
#'
#' @param x A calibration table (e.g. from [pm_calib_dominance()]). Needs a fine
#'   `sigma_nu` grid to draw smooth curves.
#' @param sigma_nu,n,beta,sigma_eps,scenario Optional values to keep.
#' @param marks `sigma_nu` values highlighted with a point; `NULL` for none.
#' @param thresholds Risk levels drawn as dashed horizontal lines.
#' @returns A `ggplot` object.
#' @export
#' @examples
#' grid <- pm_calib_dominance(sigma_nu = seq(0.01, 0.5, 0.005), n = c(3, 6, 9, 12))
#' pm_plot_risk_max(grid, beta = 0.2)
pm_plot_risk_max <- function(x,
                             sigma_nu = NULL, n = NULL, beta = NULL,
                             sigma_eps = NULL, scenario = NULL,
                             marks = c(0.05, 0.1, 0.2, 0.3, 0.4, 0.5),
                             thresholds = c(0.5, 0.8)) {

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
  sm$n_f <- factor(sm$n, levels = sort(unique(sm$n)))

  p <- ggplot2::ggplot(sm, ggplot2::aes(x = .data$sigma_nu, y = .data$risk_max,
                                        colour = .data$n_f))
  p <- .pm_thresholds(p, thresholds)
  p <- p + ggplot2::geom_line(linewidth = 0.9)

  if (!is.null(marks) && length(marks)) {
    mk <- sm[sm$sigma_nu %in% marks, , drop = FALSE]
    if (nrow(mk)) p <- p + ggplot2::geom_point(data = mk, size = 1.6)
  }
  if ("scenario" %in% names(sm))
    p <- p + ggplot2::facet_wrap(~ scenario)

  p +
    ggplot2::scale_colour_viridis_d(name = "n", end = 0.85) +
    ggplot2::scale_y_continuous(limits = c(0, 1.01), expand = c(0, 0),
                                breaks = c(seq(0, 1, 0.25), 0.8)) +
    ggplot2::labs(x = expression(sigma[nu]),
                  y = expression(paste("Risk (worst case in ", rho, ")")),
                  subtitle = sprintf("beta = %g, sigma_eps = %g",
                                     sm$beta[1], sm$sigma_eps[1])) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "bottom",
                   legend.title.position = "top")
}

# ---- Figure 4 of the paper : risk-utility trade-off ------------------------

#' Risk-utility trade-off map
#'
#' Reproduces Figure 4 of the paper: for each `(sigma_nu, n)` the curve traces
#' the (information loss, risk) couple as `rho` runs over ]0;1]. Loss on the
#' x-axis, risk on the y-axis, colour by `sigma_nu`, panels by `n`, and open
#' symbols marking a few reference dominance levels.
#'
#' Generalised on the choice of the risk metric only: pick the scenario with
#' `scenario` when the table carries several, since a single risk column can be
#' plotted at a time.
#'
#' @param x A calibration table (e.g. from [pm_calib_dominance()]).
#' @param loss Loss metric on the x-axis: `"EZ"` (mean absolute loss, default)
#'   or `"CI"` (upper confidence bound).
#' @param sigma_nu,n,beta,sigma_eps,scenario Optional values to keep.
#' @param rho_marks Dominance levels highlighted with a symbol.
#' @param thresholds Risk levels drawn as dashed horizontal lines.
#' @returns A `ggplot` object.
#' @export
#' @examples
#' grid <- pm_calib_dominance(sigma_eps = 0.031, beta = 0.2)
#' pm_plot_tradeoff(grid)
pm_plot_tradeoff <- function(x, loss = c("EZ", "CI"),
                             sigma_nu = NULL, n = NULL, beta = NULL,
                             sigma_eps = NULL, scenario = NULL,
                             rho_marks = c(0.8, 0.9, 0.95),
                             thresholds = c(0.5, 0.8)) {

  loss <- match.arg(loss)
  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required.", call. = FALSE)

  d <- .pm_plot_data(x, sigma_nu, n, beta, sigma_eps, scenario)
  if (!loss %in% names(d))
    stop("Column '", loss, "' not found in the calibration table.", call. = FALSE)
  d <- .pm_require_single(d, "beta", "pm_plot_tradeoff")
  d <- .pm_require_single(d, "sigma_eps", "pm_plot_tradeoff")
  if ("scenario" %in% names(d))
    d <- .pm_require_single(d, "scenario", "pm_plot_tradeoff")

  d <- d[order(d$sigma_nu, d$n, d$rho), ]
  d$sigma_nu_f <- factor(d$sigma_nu, levels = sort(unique(d$sigma_nu)))
  d$n_label    <- factor(d$n, levels = sort(unique(d$n)),
                         labels = paste0("n = ", sort(unique(d$n))))

  # loss floor, reached as rho -> 0: depends on sigma_eps alone
  floor_pct <- 100 * sqrt(2 / pi) * d$sigma_eps[1]

  p <- ggplot2::ggplot(d, ggplot2::aes(x = .data[[loss]], y = .data$risk,
                                       colour = .data$sigma_nu_f))
  if (loss == "EZ")
    p <- p + ggplot2::geom_vline(xintercept = floor_pct, linetype = "dotted",
                                 colour = "grey50", linewidth = 0.6)
  p <- .pm_thresholds(p, thresholds)
  p <- p + ggplot2::geom_line(ggplot2::aes(group = interaction(.data$sigma_nu,
                                                               .data$n)),
                              linewidth = 0.9)

  if (!is.null(rho_marks) && length(rho_marks)) {
    mk <- d[round(d$rho, 4) %in% round(rho_marks, 4), , drop = FALSE]
    if (nrow(mk))
      p <- p + ggplot2::geom_point(
        data = mk,
        ggplot2::aes(shape = factor(.data$rho)),
        fill = "white", size = 2.2, stroke = 0.8) +
        ggplot2::scale_shape_discrete(name = expression(rho), solid = FALSE)
  }

  ylab <- if ("scenario" %in% names(d))
    sprintf("Risk -- scenario %s", d$scenario[1]) else "Risk"
  xlab <- if (loss == "EZ")
    expression(paste("Loss of information  E(|Z| | P = ", rho, ")  (%)")) else
      expression(paste("Loss of information  upper CI bound of Z  (%)"))

  p +
    ggplot2::facet_wrap(~ n_label, nrow = 1) +
    ggplot2::scale_colour_viridis_d(name = expression(sigma[nu]), end = 0.88) +
    ggplot2::scale_y_continuous(limits = c(0, 1.02), expand = c(0, 0),
                                breaks = c(0, 0.25, 0.5, 0.8, 1)) +
    ggplot2::labs(x = xlab, y = ylab,
                  subtitle = sprintf("beta = %g, sigma_eps = %g",
                                     d$beta[1], d$sigma_eps[1])) +
    ggplot2::theme_minimal() +
    ggplot2::theme(strip.text = ggplot2::element_text(face = "bold"),
                   legend.position = "bottom",
                   legend.title.position = "top")
}

# ---- convenience method ----------------------------------------------------

#' Plot method for a dominance calibration grid
#'
#' Thin dispatcher over the three calibration plots.
#'
#' @param x A `pm_calib_dominance` table.
#' @param type `"tradeoff"` (Figure 4, default), `"profile"` (Figure 2) or
#'   `"worst"` (Figure 3, middle panel).
#' @param ... Passed on to the underlying plotting function.
#' @returns A `ggplot` object.
#' @exportS3Method plot pm_calib_dominance
plot.pm_calib_dominance <- function(x, type = c("tradeoff", "profile", "worst"),
                                    ...) {
  type <- match.arg(type)
  switch(type,
         tradeoff = pm_plot_tradeoff(x, ...),
         profile  = pm_plot_risk_profile(x, ...),
         worst    = pm_plot_risk_max(x, ...))
}
