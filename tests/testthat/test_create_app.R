test_that("create_app runs without errors.", {
  expect_is(try(create_app("myapp", app_dir = 1)), "try-error")
  expect_is(try(create_app("myapp", app_dir = tempdir(), dir_out = 1)), "try-error")
  expect_is(try(create_app("myapp", app_dir = tempdir(), include_R = 1)), "try-error")
  expect_is(try(create_app("myapp", app_dir = tempdir(), R_version = 1)), "try-error")
})
