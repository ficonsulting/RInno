context("language section")

test_that('languages returns a character vector.', {
  expect_is(languages_section('iss', 'english'), 'character')
})
