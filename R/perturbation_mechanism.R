# =============================================================================
# Applying the mechanism to an aggregated table.
#
# Y' = Y * (1 + rho^n * nu + eps),  rho = X1 / Y            (Definition 2)
# nu and eps are derived deterministically from the cell key by SHA-512 hashing
# and quantile inversion (Definitions 6-7, Proposition 8).
# =============================================================================

# ---- internal: deterministic hex -> unit interval --------------------------

# Maps the leading `ndigits` hexadecimal characters of a hash to a real number
# in ]0;1[. 13 hex digits = 52 bits, i.e. the full mantissa of a double: finer
# granularity would be lost to floating-point representation anyway.
# The result is clamped away from 0 and 1, whose normal quantiles are infinite.
.hex_to_unit <- function(hex, ndigits = 13L) {
  chars <- substr(hex, 1L, ndigits)
  m <- matrix(strtoi(unlist(strsplit(chars, "")), base = 16L),
              nrow = length(hex), byrow = TRUE)
  u <- as.vector(m %*% 16^-(seq_len(ndigits)))
  pmin(pmax(u, .Machine$double.eps), 1 - .Machine$double.eps)
}

# Deterministic string form of a numeric key. Never rely on as.character(),
# whose output is not stable across platforms or R versions. Nine decimals keep
# ample granularity for a uniform draw while tolerating the last-digit noise of
# a key aggregated in a database.
.key_to_chr <- function(key, key_digits = 9L) {
  sprintf("%.*f", key_digits, key)
}

# ---- draws from the cell keys ----------------------------------------------

#' Derive the two Gaussian draws from a cell key
#'
#' Implements Definitions 6-7 of the paper. From the cell key `CK`, the name of
#' the indicator and the aggregation operation, two distinct strings are built
#' -- one per draw -- and hashed with SHA-512. Each digest is mapped to a
#' uniform draw in ]0;1[, then turned into a Gaussian draw by quantile
#' inversion: `nu` from N(0, sigma_nu^2) and `eps` from N(0, sigma_eps^2).
#'
#' Determinism, avalanche effect and uniformity of SHA-512 (Proposition 8)
#' ensure that the same cell always receives the same perturbation, while draws
#' remain uncorrelated across indicators and between `nu` and `eps`.
#'
#' @param ck Numeric vector of cell keys in \[0;1\].
#' @param params A fully calibrated `pm_params` object.
#' @param indicator Name of the indicator the aggregate is computed from
#'   (e.g. `"turnover"`). Enters the hashed string.
#' @param operation Name of the aggregation (default `"sum"`). Enters the
#'   hashed string, so that several statistics on the same indicator get
#'   independent draws.
#' @param key_digits Number of decimals used to turn the key into a string.
#'   Fixed for reproducibility; changing it changes every draw.
#' @returns A `data.frame` with columns `ck_nu`, `ck_eps`, `nu`, `eps`.
#' @export
#' @examples
#' para <- pm_commit_dominance(pm_commit_diff(pm_params()), sigma_nu = 0.4, n = 4)
#' pm_draws(c(0.12, 0.87), para, indicator = "turnover")
pm_draws <- function(ck, params, indicator, operation = "sum",
                     key_digits = 9L) {

  stopifnot(inherits(params, "pm_params"))
  assertthat::assert_that(
    !is.na(params$mechanism$sigma_nu), !is.na(params$mechanism$sigma_eps),
    msg = "params is not fully calibrated: sigma_nu and sigma_eps must be set."
  )
  assertthat::assert_that(
    is.character(indicator), length(indicator) == 1L,
    is.character(operation), length(operation) == 1L,
    msg = "'indicator' and 'operation' must be single strings."
  )
  assertthat::assert_that(
    all(!is.na(ck)), all(ck >= 0 & ck <= 1),
    msg = "Cell keys must be non-missing and lie in [0;1]."
  )

  if (!requireNamespace("digest", quietly = TRUE))
    stop("Package 'digest' is required for SHA-512 hashing.", call. = FALSE)

  sha512 <- digest::getVDigest(algo = "sha512")   # vectorised: scales to large tables
  key_chr <- .key_to_chr(ck, key_digits)

  # "|" separator: prevents two different triplets from concatenating alike
  h_nu  <- sha512(paste(key_chr, indicator, operation, "nu",      sep = "|"),
                  serialize = FALSE)
  h_eps <- sha512(paste(key_chr, indicator, operation, "epsilon", sep = "|"),
                  serialize = FALSE)

  ck_nu  <- .hex_to_unit(h_nu)
  ck_eps <- .hex_to_unit(h_eps)

  data.frame(
    ck_nu  = ck_nu,
    ck_eps = ck_eps,
    nu     = stats::qnorm(ck_nu,  mean = 0, sd = params$mechanism$sigma_nu),
    eps    = stats::qnorm(ck_eps, mean = 0, sd = params$mechanism$sigma_eps)
  )
}

# ---- applying the mechanism ------------------------------------------------

#' Perturb an aggregated table
#'
#' Applies the mechanism of Definition 2 to a table of sums:
#' `Y' = Y (1 + rho^n nu + eps)` with `rho = X1 / Y`. The draws are obtained
#' from the cell keys via [pm_draws()], so the perturbation is reproducible:
#' re-running on the same cells and the same indicator returns the same values.
#'
#' The mechanism is defined for strictly positive totals. Cells with a
#' non-positive total are left unperturbed and flagged, with a warning: being
#' multiplicative, the noise protects neither zeros nor near-zero values.
#'
#' @param data A `data.frame` of aggregated data.
#' @param total,x1 Column names (strings): the aggregate and the largest
#'   contribution, in the same unit.
#' @param ck_var Column name of the aggregated cell key.
#' @param params A fully calibrated `pm_params` object.
#' @param indicator Name of the indicator; defaults to the `total` column name.
#' @param operation Aggregation name entering the hash (default `"sum"`).
#' @param x2 Optional column name of the second largest contribution. When
#'   given, the share `rho2 = X2 / Y` is added, enabling the scenario-II
#'   assessment.
#' @param reduce_key If `TRUE`, reduce `ck_var` to its fractional part (use it
#'   when the column holds the raw sum of individual keys, Definition 6). If
#'   `FALSE` (default), keys must already lie in \[0;1\].
#' @param key_digits Decimals used to stringify the key before hashing
#'   (default 9).
#' @returns `data` with added columns `rho`, `rho2` (when `x2` is given),
#'   `ck_nu`, `ck_eps`, and the perturbed total named `<total>_pert`.
#'   Calibration parameters and hashing settings are attached as the `pm_meta`
#'   attribute.
#' @export
#' @examples
#' para <- pm_commit_dominance(pm_commit_diff(pm_params()), sigma_nu = 0.4, n = 4)
#' tab <- data.frame(turnover = c(1000, 500), x1 = c(850, 120), ck = c(0.12, 0.87))
#' pm_perturb(tab, total = "turnover", x1 = "x1", ck_var = "ck", params = para)
pm_perturb <- function(data, total, x1, ck_var, params,
                       indicator = NULL, operation = "sum", x2 = NULL,
                       reduce_key = FALSE, key_digits = 9L) {

  stopifnot(is.data.frame(data), inherits(params, "pm_params"))
  assertthat::assert_that(
    !is.na(params$mechanism$sigma_nu), !is.na(params$mechanism$sigma_eps),
    !is.na(params$mechanism$n),
    msg = paste0("params is not fully calibrated: run pm_commit_diff() and ",
                 "pm_commit_dominance() first.")
  )

  cols <- c(total, x1, ck_var, x2)
  missing <- setdiff(cols, names(data))
  if (length(missing))
    stop("Column(s) not found in 'data': ", paste(missing, collapse = ", "),
         call. = FALSE)

  if (is.null(indicator)) indicator <- total
  out_col  <- paste0(total, "_pert")
  new_cols <- c("rho", if (!is.null(x2)) "rho2", "ck_nu", "ck_eps", out_col)
  clash <- intersect(new_cols, names(data))
  if (length(clash))
    stop("These column names would be overwritten: ",
         paste(clash, collapse = ", "), call. = FALSE)

  Y  <- data[[total]]
  X1 <- data[[x1]]
  ck <- data[[ck_var]]

  # --- keys ---------------------------------------------------------------
  if (isTRUE(reduce_key)) ck <- ck - floor(ck)
  if (any(is.na(ck)) || any(ck < 0 | ck > 1))
    stop("Cell keys must be non-missing and lie in [0;1]. Use ",
         "reduce_key = TRUE if the column holds the raw sum of individual keys.",
         call. = FALSE)

  # --- dominance ----------------------------------------------------------
  ok <- !is.na(Y) & Y > 0 & !is.na(X1)
  if (any(!ok))
    warning(sprintf(paste0("%d cell(s) with a missing or non-positive total ",
                           "left unperturbed: the multiplicative noise does not ",
                           "protect zeros or near-zero values."), sum(!ok)),
            call. = FALSE)

  rho <- rep(NA_real_, nrow(data))
  rho[ok] <- X1[ok] / Y[ok]
  if (any(!is.na(rho) & rho > 1))
    warning(sprintf("%d cell(s) with x1 > total (rho > 1): check the inputs.",
                    sum(!is.na(rho) & rho > 1)), call. = FALSE)

  # --- draws and perturbation ---------------------------------------------
  d <- pm_draws(ck, params, indicator = indicator, operation = operation,
                key_digits = key_digits)

  n  <- params$mechanism$n
  Yp <- rep(NA_real_, nrow(data))
  Yp[ok]  <- Y[ok] * (1 + rho[ok]^n * d$nu[ok] + d$eps[ok])
  Yp[!ok] <- Y[!ok]                       # left as-is

  res <- data
  res$rho <- rho
  if (!is.null(x2)) {
    rho2 <- rep(NA_real_, nrow(data))
    rho2[ok] <- data[[x2]][ok] / Y[ok]
    res$rho2 <- rho2
  }
  res$ck_nu  <- d$ck_nu
  res$ck_eps <- d$ck_eps
  res[[out_col]] <- Yp

  attr(res, "pm_meta") <- list(
    params     = params,
    total      = total, x1 = x1, x2 = x2, ck_var = ck_var,
    perturbed  = out_col,
    indicator  = indicator, operation = operation,
    reduce_key = reduce_key, key_digits = key_digits,
    n_cells    = nrow(data), n_unperturbed = sum(!ok),
    package_version = as.character(utils::packageVersion("dominoise")),
    date = Sys.time()
  )
  res
}
