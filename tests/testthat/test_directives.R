test_that("directives returns a character vector.", {
  expect_is(directives("myapp", TRUE, "3.3.2"), "character")
})
