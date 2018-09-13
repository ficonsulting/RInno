context("sanitize_R_version")

test_that("Version strings are valid", {
  expect_error(sanitize_R_version("3"))
  expect_error(sanitize_R_version("3>=3.5.0"))
  expect_error(sanitize_R_version("3 b.0"))
})

test_that("Version strings are actually sanitized", {
  expect_equal(sanitize_R_version(" >= 5 .4 2.  0", clean=TRUE), "5.42.0")
  expect_equal(sanitize_R_version(">= 3. 5  "), ">=3.5.0")
})

test_that("Minimum required version is checked", {
  expect_error(sanitize_R_version(">=2.14"))
  expect_equal(sanitize_R_version(">=2.14", R_version_min=NULL), ">=2.14.0")
})
