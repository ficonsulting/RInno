context("icons section")

test_that("icons returns a character.", {
  expect_is(suppressWarnings(icons_section("iss", "This is an app desc", "myappicon.ico", F)), "character")
})
