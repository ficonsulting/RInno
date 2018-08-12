context("Tasks, Code and Run sections")

test_that("tasks, code and run return character vectors.", {
  expect_is(tasks_section("iss", TRUE), "character")
  expect_is(code_section("iss"), "character")
  expect_is(run_section("iss"), "character")
})
