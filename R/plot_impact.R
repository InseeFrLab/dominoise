#' Observed perturbation against dominance
#'
#' Plots the relative deviation actually undergone by each cell against its
#' dominance level, and overlays the theoretical envelope predicted before any
#' data were touched: the level-`level` confidence band of the relative loss
#' (Definition 4) and the mean absolute loss (Proposition 3).
#'
#' The mechanism being analytical, the cloud of points should fill the band and
#' straddle the mean lines. That agreement is the natural consistency check
#' between what was promised at calibration time and what the table received.
#'
#' @param x A table returned by [pm_perturb()].
#' @param level Confidence level of the band (default 0.95).
#' @param colour_by Optional column name used to colour the points (e.g. a
#'   publication stratum).
#' @param alpha Point transparency; lower it on large tables.
#' @param n_grid Number of dominance values used to draw the envelope.
#' @returns A `ggplot` object.
#' @export
#' @examples
#' set.seed(123)
#' N = 1000
#' params <- pm_commit_dominance(pm_commit_diff(pm_params()), sigma_nu = 0.4, n = 4)
#' rhos <- runif(N, 0, 1)
#' tab <- data.frame(turnover = runif(N, 0,1000), ck = runif(N, 0, 1))
#' tab$x1 <- tab$turnover * rhos
#' res <- pm_perturb(tab, "turnover", "x1", "ck", params)
#' pm_plot_impact(res)
pm_plot_impact <- function(x, level = 0.95, colour_by = NULL,
                           alpha = 0.35, n_grid = 200) {

  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required.", call. = FALSE)

  m <- attr(x, "pm_meta")
  if (is.null(m))
    stop("This table has no 'pm_meta' attribute: was it produced by pm_perturb()?",
         call. = FALSE)

  d <- as.data.frame(x)
  Y  <- d[[m$total]]
  Yp <- d[[m$perturbed]]
  ok <- !is.na(Y) & Y > 0 & !is.na(Yp) & !is.na(d$rho)
  d  <- d[ok, , drop = FALSE]
  d$.dev <- 100 * (d[[m$perturbed]] - d[[m$total]]) / d[[m$total]]

  p <- m$params$mechanism
  g <- data.frame(rho = seq(min(d$rho), max(d$rho), length.out = n_grid))
  g$ci <- 100 * assess_loss_ci(g$rho, p$sigma_nu, p$sigma_eps, p$n, level)
  g$ez <- 100 * assess_loss_expectation(g$rho, p$sigma_nu, p$sigma_eps, p$n)

  gg <- ggplot2::ggplot()

  # theoretical envelope, drawn underneath the observations
  gg <- gg +
    ggplot2::geom_ribbon(
      data = g,
      ggplot2::aes(x = .data$rho, ymin = -.data$ci, ymax = .data$ci),
      fill = "grey70", alpha = 0.30) +
    ggplot2::geom_line(data = g, ggplot2::aes(x = .data$rho, y = .data$ez),
                       colour = "grey30", linetype = "dashed") +
    ggplot2::geom_line(data = g, ggplot2::aes(x = .data$rho, y = -.data$ez),
                       colour = "grey30", linetype = "dashed") +
    ggplot2::geom_hline(yintercept = 0, colour = "grey50", linewidth = 0.3)

  gg <- gg + if (is.null(colour_by)) {
    ggplot2::geom_point(data = d, ggplot2::aes(x = .data$rho, y = .data$.dev),
                        alpha = alpha, size = 1.1)
  } else {
    if (!colour_by %in% names(d))
      stop("Column '", colour_by, "' not found.", call. = FALSE)
    ggplot2::geom_point(data = d,
                        ggplot2::aes(x = .data$rho, y = .data$.dev,
                                     colour = .data[[colour_by]]),
                        alpha = alpha, size = 1.1)
  }

  gg +
    ggplot2::labs(
      x = expression(paste("Dominance  ", rho, " = ", X[1] / Y)),
      y = "Observed relative deviation (%)",
      caption = sprintf(
        paste0("Band: %.0f%% confidence interval of Z. Dashed: mean absolute ",
               "loss. sigma_nu = %g, sigma_eps = %g, n = %g."),
        100 * level, p$sigma_nu, p$sigma_eps, p$n)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "bottom")
}
