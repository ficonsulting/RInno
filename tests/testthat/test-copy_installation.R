context("Copying installation files")

test_that("copy_installation should copy files into 4 locations.", {
  temp_dir <- tempdir()
  if (!dir.exists(temp_dir)) dir.create(temp_dir)
  expect_equal(sum(copy_installation(temp_dir)), 4)
})
