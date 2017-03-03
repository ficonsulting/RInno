expect_that("setup returns a character vector.", {
  expect_is(class(setup("iss", "app", "0.0.1")), "character")
})
