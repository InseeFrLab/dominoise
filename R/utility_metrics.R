# =============================================================================
#
# Utility metrics -- conditional information loss of the mechanism.
#
# =============================================================================


# Conditional standard deviation of the relative loss Z at dominance rho:
#   vsigma(rho) = sqrt(rho^(2n) * sigma_nu^2 + sigma_eps^2)    (Proposition 1)
# Internal building block shared by every loss and risk metric.
.sd_z <- function(rho, sigma_nu, sigma_eps, n) {
  sqrt(rho^(2 * n) * sigma_nu^2 + sigma_eps^2)
}


#' Conditional expectation of the absolute relative loss |Z|
#'
#' `E(|Z| | P = rho) = sqrt(2 (rho^(2n) sigma_nu^2 + sigma_eps^2) / pi)`
#' (Proposition 3 of the paper): the average relative perturbation undergone by
#' a cell of dominance `rho`. Contrary to the differencing step -- where letting
#' rho -> 0 makes the sigma_nu term vanish -- the sigma_nu contribution is kept
#' in full here.
#'
#' @param rho Dominance share X1/Y in (0,1]. Recycled.
#' @param sigma_nu,sigma_eps,n Mechanism parameters. Recycled.
#' @returns E(|Z| | rho) as a relative quantity (multiply by 100 for percent).
#' @export
#' @examples
#' assess_loss_expectation(rho = 1, sigma_nu = 0.3, sigma_eps = 0.03, n = 6)
assess_loss_expectation <- function(rho, sigma_nu, sigma_eps, n) {
  sqrt(2 / pi) * .sd_z(rho, sigma_nu, sigma_eps, n)
}

#' Confidence-interval bound of the relative loss Z
#'
#' Upper bound `L(rho) = q * sqrt(rho^(2n) sigma_nu^2 + sigma_eps^2)` of the
#' level-`level` confidence interval `[-L(rho), L(rho)]` of Z (Definition 4 of
#' the paper), with `q` the `(1+level)/2` quantile of the standard normal. The
#' interval is symmetric, so this single value gives both bounds.
#'
#' @param rho Dominance share X1/Y in (0,1]. Recycled.
#' @param sigma_nu,sigma_eps,n Mechanism parameters. Recycled.
#' @param level Confidence level (default 0.95).
#' @returns The upper bound L(rho) as a relative quantity.
#' @export
#' @examples
#' assess_loss_ci(rho = 1, sigma_nu = 0.3, sigma_eps = 0.03, n = 6)
assess_loss_ci <- function(rho, sigma_nu, sigma_eps, n, level = 0.95) {
  stats::qnorm((1 + level) / 2) * .sd_z(rho, sigma_nu, sigma_eps, n)
}
