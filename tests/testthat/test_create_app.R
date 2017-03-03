test_that("create_app runs without errors.", {
  expect_error(create_app("myapp", app_dir = 1))
  expect_error(create_app("myapp", app_dir = tempdir(), dir_out = 1))
  expect_error(create_app("myapp", app_dir = tempdir(), include_R = 1))
  expect_error(create_app("myapp", app_dir = tempdir(), R_version = 1))
  expect_error(create_app("myapp", app_dir = tempdir(), R_version = "5.3.2"))

  expect_is(create_app("myapp", tempdir()), "character")
})
