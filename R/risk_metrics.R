# =============================================================================
#
# Risk metrics
#
# =============================================================================

#' Compute the upper bound of the differencing risk, following the proposition 7
#' of the paper.
#'
#' @param sigma_eps double
#' @param beta double
#'
#' @returns double vector
#' @export
#' @importFrom stats pnorm
#' @importFrom rlang .data
#' @examples
#' assess_risk_diff(sigma_eps = 0.1, beta = 0.2)
assess_risk_diff <- function(sigma_eps, beta) {

  2 * stats::pnorm(beta/sigma_eps) - 1

}


#' Scenario-I (dominance) risk measure
#'
#' Probability that an external attacker infers the dominant contribution X1 to
#' within +/- beta (Proposition 5 of the paper):
#' `mu_I(rho) = F_Z((1+beta)rho - 1) - F_Z((1-beta)rho - 1)`, with Z the
#' relative loss at dominance rho.
#'
#' @param rho Dominance share X1/Y in (0,1]. Recycled.
#' @param sigma_nu,sigma_eps,n Mechanism parameters. Recycled.
#' @param beta Accuracy threshold of the inference.
#' @returns mu_I(rho), vectorised.
#' @export
#' @examples
#' assess_risk_I(rho = 0.85, sigma_nu = 0.3, sigma_eps = 0.03, n = 6, beta = 0.2)
assess_risk_I <- function(rho, sigma_nu, sigma_eps, n, beta) {

  sd <- .sd_z(rho, sigma_nu, sigma_eps, n)
  stats::pnorm(((1 + beta) * rho - 1) / sd) -
    stats::pnorm(((1 - beta) * rho - 1) / sd)

}

#' Scenario-II (p%-rule) risk measure
#'
#' Probability that an insider contributing `X2` to the aggregate infers the
#' dominant contribution `X1` to within +/- beta, by subtracting their own
#' contribution from the disseminated total (Proposition 5 of the paper):
#' `mu_II(rho, rho2) = F_Z((1+beta)rho + rho2 - 1) - F_Z((1-beta)rho + rho2 - 1)`,
#' with `Z` the relative loss at dominance `rho`.
#'
#' The worst case (IIa) has the two largest contributors sharing the whole cell
#' (`rho + rho2 = 1`); the relaxed case (IIb) leaves a residual share to the
#' other contributors, typically `rho + rho2 = 0.95`.
#'
#' @param rho Share of the largest contribution, X1/Y, in (0,1]. Recycled.
#' @param rho2 Share of the second contribution, X2/Y. Recycled.
#' @param sigma_nu,sigma_eps,n Mechanism parameters. Recycled.
#' @param beta Accuracy threshold of the inference.
#' @returns mu_II(rho, rho2), vectorised.
#' @export
#' @examples
#' # worst case IIa at rho = 0.5
#' assess_risk_II(0.5, 0.5, sigma_nu = 0.4, sigma_eps = 0.031, n = 4, beta = 0.1)
assess_risk_II <- function(rho, rho2, sigma_nu, sigma_eps, n, beta) {
  v <- .sd_z(rho, sigma_nu, sigma_eps, n)
  stats::pnorm(((1 + beta) * rho + rho2 - 1) / v) -
    stats::pnorm(((1 - beta) * rho + rho2 - 1) / v)
}
