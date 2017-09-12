test_that("icons returns a character.", {
  expect_is(suppressWarnings(icons("iss", "This is an app desc", "myappicon.ico", F)), "character")
})
