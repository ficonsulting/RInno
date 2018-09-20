context("standardize_pkgs")

test_that("Package dependencies are installed", {
  expect_error(standardize_pkgs("test"))
  expect_error(standardize_pkgs(c(test = ">1.0")))
})

test_that("Packages are standardized consistently", {
  pkgs1 <- standardize_pkgs(c("shiny", "rmarkdown", "jsonlite"))
  pkgs2 <- standardize_pkgs(c("shiny", "rmarkdown", jsonlite = ">=1.5"))
  pkgs3 <- standardize_pkgs(c(shiny = paste0(">=", packageVersion("shiny")),
                              rmarkdown = paste0(">=", packageVersion("rmarkdown")),
                              jsonlite = paste0(">=", packageVersion("jsonlite"))))
  expect_identical(pkgs1, pkgs2, pkgs3)
})
