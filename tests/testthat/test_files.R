test_that("files returns a character vector.", {
  expect_is(files("iss", tempdir()), "character")
})
