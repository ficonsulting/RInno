test_that("copy_deployment should copy files into three locations.", {
  expect_equal(sum(copy_installation(tempdir())), 2)
})
