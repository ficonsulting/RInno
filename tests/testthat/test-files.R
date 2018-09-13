context("files section")

test_that("files returns a character vector.", {
  app_dir <- tempdir()
  expect_is(files_section("iss", "myapp", dirname(app_dir), "ie"), "character")
})
