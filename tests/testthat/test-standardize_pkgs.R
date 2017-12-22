context("test-standardize_pkgs.R")

test_that("Uninstalled packages through errors", {
  expect_error(RInno::standardize_pkgs("test"))
})

test_that("Packages are standardized for config.cfg", {
  expect_equal(
    standardize_pkgs(c("shiny", "RInno", "dplyr")),
    standardize_pkgs(c(shiny = paste0(">=", packageVersion("shiny")),
                       RInno = paste0(">=", packageVersion("RInno")),
                       dplyr = paste0(">=", packageVersion("dplyr"))))
  )
})
