context("test-installation-ensure.R")
source("../../inst/installation/ensure.R")

test_that("CRAN version is consistent with the numeric version", {
  jpeg_ver = "0.1.8" # Note: CRAN version string is "0.1-8"
  expect_identical(pkgVersionCRAN("jpeg"), numeric_version(jpeg_ver), jpeg_ver)
})
