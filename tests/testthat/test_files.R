test_that("files returns a character vector.", {
  expect_is(files_section("iss", tempdir()), "character")
})
