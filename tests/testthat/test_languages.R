test_that('languages returns a character vector.', {
  expect_is(languages('iss', 'english'), 'character')
})
