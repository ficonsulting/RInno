#' Package app into electron with nativefier
#'
#' @export
nativefier_app <- function(app_name, app_dir) {
  # Get Nodejs, npm and nativefier
  if (!node_exists()) {
    installr::install.nodejs()
  }
  system(glue::glue("npm install nativefier -g"))

  # start the app in a separate R session
  system(paste0("R -e ", '"shiny::runApp(', sprintf("'%s', port=1984)", app_dir)), wait = FALSE)

  # use nativefier to package it into an electron app
  oldwd <- getwd()
  setwd(app_dir)

  nativefier_loc <- "nativefier-app"
  local_url <- "http://127.0.0.1:1984/"
  system(
    glue::glue(
      "nativefier --name {glue::double_quote(app_name)} {glue::double_quote(local_url)} {glue::double_quote(nativefier_loc)}"
    )
  )
  setwd(oldwd)
}
