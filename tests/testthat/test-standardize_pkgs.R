context("test-standardize_pkgs.R")

test_that("Uninstalled packages through errors", {
  expect_error(RInno::standardize_pkgs("test"))
})
