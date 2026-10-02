test_that("loss metrics reach their closed-form limits", {
  expect_equal(assess_loss_expectation(0, 0.3, 0.03, 6), sqrt(2 / pi) * 0.03)
  expect_equal(assess_loss_expectation(1, 0.3, 0.03, 6),
               sqrt(2 / pi) * sqrt(0.3^2 + 0.03^2))
  expect_equal(assess_loss_ci(1, 0.3, 0, 6, level = 0.9), qnorm(0.95) * 0.3)
})

test_that("pm_sigma_eps inverts the differencing risk (Proposition 7)", {
  g <- expand.grid(beta = c(0.05, 0.1, 0.2), tau = c(0.5, 0.8, 0.95))
  expect_equal(assess_risk_diff(pm_sigma_eps(g$beta, g$tau), g$beta), g$tau)
})

test_that("scenario II reduces to scenario I when rho2 = 0", {
  rho <- seq(0.1, 1, 0.1)
  expect_equal(assess_risk_II(rho, 0, 0.3, 0.03, 6, 0.2),
               assess_risk_I(rho, 0.3, 0.03, 6, 0.2))
})

test_that("risks are probabilities and monotone in the parameters", {
  rho <- seq(0.01, 1, 0.01)
  r <- assess_risk_I(rho, 0.3, 0.03, 6, 0.2)
  expect_true(all(r >= 0 & r <= 1))
  rmax <- function(sn, n) max(assess_risk_I(rho, sn, 0.03, n, 0.2))
  expect_gt(rmax(0.2, 6), rmax(0.4, 6))   # decreasing in sigma_nu
  expect_lt(rmax(0.3, 3), rmax(0.3, 9))   # increasing in n
})

test_that("scenario-I risk matches a Monte-Carlo simulation", {
  skip_on_cran()
  set.seed(42)
  rho <- 0.85; sn <- 0.3; se <- 0.03; n <- 6; beta <- 0.2
  z  <- rho^n * rnorm(2e5, sd = sn) + rnorm(2e5, sd = se)
  hit <- abs((1 + z) - rho) / rho < beta        # |Y' - X1| / X1 < beta, Y = 1
  expect_equal(mean(hit), assess_risk_I(rho, sn, se, n, beta), tolerance = 0.01)
})
