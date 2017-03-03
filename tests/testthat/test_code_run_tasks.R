test_that("tasks, code and run return character vectors.", {
  expect_is(tasks("iss", TRUE), "character")
  expect_is(code("iss"), "character")
  expect_is(run("iss"), "character")
})
