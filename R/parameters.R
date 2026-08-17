
#' Create the perturbation-parameter object containing all the parameters
#' of the noise.
#'
#' @param beta_dominance,tau_dominance Accuracy threshold and risk ceiling for
#'   scenario I (dominance rule). Defaults to 0.2 / 0.5.
#' @param beta_prule,tau_prule,s_prule Threshold, ceiling and cumulated share of
#'   the two largest contributors for scenario II (p%-rule). `s_prule = 0.95`
#'   is the relaxed case IIb in the paper; `1` would be the worst case IIa.
#'   Defaults to 0.1 / 0.9 / 0.95.
#' @param beta_diff,tau_diff Threshold and ceiling for the differencing
#'   scenario. Defaults: 0.05 / 0.95.
#' @param sigma_nu,sigma_eps,n Mechanism parameters, filled in during
#'   calibration. Left as `NA` until decided.
#'
#' @returns pm_params object
#' @export
#'
#' @examples
#' para <- pm_params()
#' para
pm_params <- function(beta_dominance = 0.2,  tau_dominance = 0.9,
                      beta_prule     = 0.1,  tau_prule     = 0.9, s_prule = 0.95,
                      beta_diff      = 0.05, tau_diff      = 0.95,
                      sigma_nu = NA_real_, sigma_eps = NA_real_, n = NA_real_) {
  structure(
    list(
      policy = list(
        dominance = list(beta = beta_dominance, tau = tau_dominance),
        prule     = list(beta = beta_prule, tau = tau_prule, s = s_prule),
        diff      = list(beta = beta_diff,  tau = tau_diff)
      ),
      mechanism = list(
        sigma_nu  = sigma_nu,
        sigma_eps = sigma_eps,
        n         = n
      )
    ),
    class = "pm_params"
  )
}


#' Method to print pm_params object
#'
#' @param x pm_params object
#' @param ... Ignored
#'
#' @returns pm_params object x
#' @exportS3Method
#'
#' @examples
#' para <- pm_params()
#' para
print.pm_params <- function(x, ...) {
  fmt <- function(v) if (is.na(v)) "<not set>" else format(v)
  cat("<pm_params>\n")
  cat("  policy\n")
  cat(sprintf("    dominance : beta = %g, tau = %s\n",
              x$policy$dominance$beta, fmt(x$policy$dominance$tau)))
  cat(sprintf("    p%%-rule   : beta = %g, tau = %s, s = %g\n",
              x$policy$prule$beta, fmt(x$policy$prule$tau), x$policy$prule$s))
  cat(sprintf("    diff      : beta = %g, tau = %s\n",
              x$policy$diff$beta, fmt(x$policy$diff$tau)))
  cat("  parameters of the mechanism\n")
  cat(sprintf("    sigma_nu  = %s\n", fmt(x$mechanism$sigma_nu)))
  cat(sprintf("    sigma_eps = %s\n", fmt(x$mechanism$sigma_eps)))
  cat(sprintf("    n         = %s\n", fmt(x$mechanism$n)))
  invisible(x)
}

