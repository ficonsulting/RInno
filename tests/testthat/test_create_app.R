test_that("create_app runs without errors.", {
  x <- try(create_app('myapp', app_dir = tempdir(), pkgs = 1))
  expect_is(x, 'try-error')
})
