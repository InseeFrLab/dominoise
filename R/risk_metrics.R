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
#'
#' @examples
#' assess_risk_diff(sigma_eps = 0.1, beta = 0.2)
assess_risk_diff <- function(sigma_eps, beta) {

  2 * pnorm(beta/sg_eps) - 1

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

