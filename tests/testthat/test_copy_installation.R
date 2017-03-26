test_that("copy_installation should copy files into 4 locations.", {
  expect_equal(sum(copy_installation(tempdir())), 4)
})
