test_that("create_app runs without errors.", {
  v <- try(create_app(1))
  w <- try(create_app("myapp", app_dir = 1))
  x <- try(create_app("myapp", app_dir = tempdir(), dir_out = 1))
  y <- try(create_app("myapp", app_dir = tempdir(), include_R = 1))
  z <- try(create_app("myapp", app_dir = tempdir(), R_version = 1))

  expect_is(v, "try-error")
  expect_is(w, "try-error")
  expect_is(x, "try-error")
  expect_is(y, "try-error")
  expect_is(z, "try-error")
})
