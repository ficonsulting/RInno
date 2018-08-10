context("directive checks")

test_that("directives returns a character vector.", {
  expect_is(directives_section("myapp", TRUE, "3.3.2", FALSE, "1.21.1"), "character")
})
