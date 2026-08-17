# =============================================================================
#
# Calibration step 1 : Set sigma_epsilon the amount of noise
# to inject to protect differencing inferences.
#
# =============================================================================



#' Smallest sigma_eps guaranteeing the differencing-risk ceiling
#'
#' Closed-form inversion of the worst-case upper bound of the differencing
#' risk (Proposition 7 of the paper)
#'
#' @param beta,tau Numeric. Accuracy threshold and risk ceiling.
#' @return sigma_eps, vectorised over `beta`/`tau`.
#' @export
pm_sigma_eps <- function(beta, tau) {
  stopifnot(all(beta > 0), all(tau > 0 & tau < 1))
  beta / stats::qnorm((1 + tau) / 2)
}

# Loss multipliers at rho -> 0 (all three are linear in sigma_eps).
.loss_factors <- function(level = 0.95) {
  list(
    ez  = sqrt(2 / pi), # E|Z| == ez * sigma_eps
    ci = stats::qnorm((1 + level) / 2))  # upper CI upper bound == ci * sigma_eps
}

#' Calibration of the differencing noise (sigma_epsilon)
#'
#' @param params object pm_params
#' @param beta real vector of beta values (accuracy level of the inference)
#' @param tau real vector of tau values (ceiling risk level)
#' @param level confidence level for the confidence intervall of the relative loss
#'
#' @returns data.frame and pm_calib_diff object
#' @export
#'
#' @details
#' By default, the function returns the results for some beta and tau values
#' beta in (0.05, 0.1, 0.15, 0.2, 0.25) and
#' tau in s(0.5, 0.55, 0.6, 0.65, ..., 0.90, 0.95)
#'
#'
#' @examples
#' # default behaviour
#' pm_calib_diff()
pm_calib_diff <- function(params = NULL, beta = NULL, tau = NULL, level = 0.95) {

  assertthat::assert_that(
    (is.null(beta) && is.null(tau)) || all( beta > 0 & beta < 1 & tau > 0 & tau < 1),
    msg = "All beta and tau values have to be reals in (0;1)."
  )

  if(is.null(params) & is.null(beta)){

    betas <- c(0.05, 0.1, 0.15, 0.2, 0.25)
    taus <- seq(0.5, 0.95, 0.05)

  }else if(is.null(beta)) {

    stopifnot(inherits(params, "pm_params"))

    betas <- params$policy$diff$beta
    taus  <- params$policy$diff$tau

  }else{

    betas <- beta
    taus <- tau

  }

  g  <- expand.grid(beta = betas, tau = taus, KEEP.OUT.ATTRS = FALSE)
  se <- pm_sigma_eps(g$beta, g$tau)
  f  <- .loss_factors(level)

  out <- data.frame(
    beta        = g$beta,
    tau         = g$tau,
    sigma_eps   = se,
    EZ = 100 * f$ez * se,
    CI = 100 * f$ci * se
  )
  out <- out[order(out$beta, out$tau), ]
  rownames(out) <- NULL
  attr(out, "level") <- level
  class(out) <- c("pm_calib_diff", "data.frame")
  out

}


#' Plot method for a differencing calibration grid
#'
#' Draws the risk-utility frontier of the differencing step: the level risk ceiling `tau`
#' (guaranteed maximum differencing risk) against the relative loss (Z) level it costs
#' (either expectation of |Z| or upper bound of the confidence interval of it),
#' one curve per `beta`.
#'
#' @param x A `pm_calib_diff` grid, as returned by [pm_calib_diff()].
#' @param loss One of `"CI"` (for upper bound of the confidence interval),
#' `"EZ"` (for expectation of the absolute relative loss |Z|):
#' which loss metric to use on the x-axis.
#' @param ... Ignored, for compatibility with the `plot()` generic.
#' @return The `ggplot` object, invisibly.
#' @exportS3Method
#' @examples
#' plot(pm_calib_diff())
plot.pm_calib_diff <- function(x, loss = c("CI", "EZ"), ...) {
  loss <- match.arg(loss)
  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required to plot a 'pm_calib_diff' object.")

  xcol <- switch(loss, CI = "CI", EZ = "EZ")
  xlab <- switch(
    loss,
    CI = sprintf("Relative loss -- upper %.0f%% CI bound of Z (%%)", 100 * attr(x, "level")),
    EZ = "Relative loss -- mean absolute loss E|Z| (%)"
  )

  df <- as.data.frame(x)
  df$beta <- factor(df$beta)
  df <- df[order(df$beta, df[[xcol]]), ]

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = .data[[xcol]],
      y = .data$tau,
      colour = .data$beta, group = .data$beta
    )
  ) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 1.4) +
    ggplot2::labs(
      x = xlab, y = "Ceiling on max differencing risk (tau)",
      colour = "Accuracy level\n of the difference (beta)",
      title = "Differencing scenario: risk ceiling vs. information loss") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "bottom",
                   legend.title.position = "top")

  return(p)
}


#' Commit the differencing decision into the parameter object
#'
#' Once `beta_diff` and `tau_diff` are chosen (typically after exploring with
#' [pm_calib_diff()]), this fills `sigma_eps` in the `pm_params` object and
#' records the two policy values. It is the single place where step 1 mutates
#' `params`.
#'
#' @param params A `pm_params` object.
#' @param beta,tau The chosen threshold and ceiling. Default to the values
#'   already stored in the `diff` policy. Must be single values.
#' @param level Confidence level used only for the informative message.
#' @return The updated `pm_params` (returned invisibly).
#' @export
#' @examples
#' parameters <- pm_params()
#'
#' # beta and tau already set in the pm_params object:
#' parameters <- pm_commit_diff(parameters)
#' parameters
#'
#' # if an another choice is preferred (after calibration search)
#' parameters <- pm_commit_diff(parameters, beta = 0.1, tau = 0.9)
#' parameters
pm_commit_diff <- function(
    params,
    beta  = params$policy$diff$beta,
    tau   = params$policy$diff$tau,
    level = 0.95
) {

  stopifnot(inherits(params, "pm_params"))

  if (length(beta) != 1L || length(tau) != 1L)
    stop("'beta' and 'tau' must be single values.", call. = FALSE)

  se <- pm_sigma_eps(beta, tau)

  params$policy$diff$beta <- beta
  params$policy$diff$tau <- tau
  params$mechanism$sigma_eps <- se

  f <- .loss_factors(level)
  message(
    sprintf(
      paste0("Differencing step committed: beta = %g, tau = %g  ->  sigma_eps = %.4f\n",
             "  loss floor at rho -> 0:  E|Z| = %.2f%%,  upper %.0f%% CI = %.2f%%"),
      beta, tau, se, 100 * f$ez * se, 100 * level, 100 * f$ci * se
    )
  )

  invisible(params)
}






