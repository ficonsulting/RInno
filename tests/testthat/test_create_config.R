test_that("create_config builds a valid json file.", {
  create_config("myapp", "3.3.2", tempdir(), pkgs = c("jsonlite", "shiny", "magrittr"))
  config <- fromJSON(file.path(tempdir(), 'config.cfg'))

  expect_is(config, 'list')
})

test_that("create_config accepts only bitbucket and github repos.", {
  expect_error(create_config("myapp", "3.3.2", "app", pkgs = c("jsonlite", "shiny", "magrittr"), app_repo_url = "www.myrepo.com"))
})
