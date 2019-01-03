#' Package app into electron
#' @inheritParams create_app
#' @inheritParams icons_section
#' @export

electron_app <- function(app_name, app_dir, nativefier_opts, app_icon = "default.ico") {
  cat("\nBuilding stand-alone UI with Electron...\n")

  # Reset defaults if empty
  reset_formals(electron_app)

  # Get Nodejs, npm and nativefier
  if (!node_exists()) {
    cat("\nNodejs is not installed...\n")
    ans <- utils::menu(c("Yes", "No"), title = "Would you like to install it?")
    if (ans == 1) install_nodejs()
    else stop("Change the user_browser to 'chrome', 'firefox' or 'ie' if you do not have Nodejs installed.")
  }
  system(glue::glue("npm install nativefier -g"))

  # start the app in a separate R session
  system(paste0("R -e ", '"shiny::runApp(', sprintf("'%s', port=1984)", app_dir)), wait = FALSE)

  # use nativefier to package it into an electron app
  oldwd <- getwd()
  setwd(app_dir)

  nativefier_loc <- "nativefier-app"
  local_url <- "http://127.0.0.1:1984/"
  opts_str <- paste(nativefier_opts, collapse = " ")

  cmd <- glue::glue(
    "nativefier --name {glue::double_quote(app_name)} --icon {app_icon} {opts_str} {glue::double_quote(local_url)} {glue::double_quote(nativefier_loc)}"
  )
  cat("\n", cmd, "\n")
  system(cmd)
  setwd(oldwd)
}
