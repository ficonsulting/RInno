test_that("icons returns a character.", {
  expect_is(icons("iss", "This is an app desc", "myappicon.ico", F), "character")
})
