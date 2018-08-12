context("setup section")

test_that("setup returns a character vector.", {
  expect_is(suppressWarnings(setup_section("iss", "app", "0.0.1")), "character")
})
