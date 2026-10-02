
test_that("draws match reference values computed independently", {
  d <- pm_draws(c(0.12, 0.87), para, indicator = "turnover")
  expect_equal(d$ck_nu,  c(0.3001429375600242, 0.6236416566988727), tolerance = 1e-12)
  expect_equal(d$ck_eps, c(0.056033698014645195, 0.2439149014916555), tolerance = 1e-12)
  expect_equal(d$nu,  c(-0.20959578150561958, 0.1260236900986402),   tolerance = 1e-10)
  expect_equal(d$eps, c(-0.04053566782790285, -0.01769840350100954), tolerance = 1e-10)
})

test_that("draws are deterministic and order-independent", {
  ck <- c(0.12, 0.87, 0.5)
  expect_identical(pm_draws(ck, para, "turnover"), pm_draws(ck, para, "turnover"))
  expect_identical(pm_draws(rev(ck), para, "turnover")$nu,
                   rev(pm_draws(ck, para, "turnover")$nu))
})

test_that("indicator, operation and draw label give independent draws", {
  a <- pm_draws(0.12, para, "turnover")
  expect_false(a$nu == pm_draws(0.12, para, "payroll")$nu)
  expect_false(a$nu == pm_draws(0.12, para, "turnover", operation = "mean")$nu)
  expect_false(a$ck_nu == a$ck_eps)
})

test_that("key_digits absorbs noise beyond the 9th decimal", {
  expect_identical(pm_draws(0.12, para, "turnover"),
                   pm_draws(0.12 + 1e-12, para, "turnover"))
})

test_that("draws are uniform / Gaussian with the right scale", {
  set.seed(1)
  d <- pm_draws(runif(5000), para, "turnover")
  expect_gt(stats::ks.test(d$ck_nu, "punif")$p.value, 0.001)
  expect_equal(stats::sd(d$nu), 0.4, tolerance = 0.05)
  expect_lt(abs(stats::cor(d$nu, d$eps)), 0.05)
})

test_that(".hex_to_unit maps and clamps correctly", {
  expect_equal(dominoise:::.hex_to_unit("8000000000000"), 0.5)
  u <- dominoise:::.hex_to_unit(c("0000000000000", "fffffffffffff"))
  expect_true(all(u > 0 & u < 1))
})
