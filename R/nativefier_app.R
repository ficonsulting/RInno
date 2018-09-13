#' Package app into electron with nativefier
#'
#' @export
nativefier_app <- function(app_name, app_dir, ...) {
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
  opts_str = create_opts_str(...)
  cmd <- glue::glue(
   "nativefier --name {glue::double_quote(app_name)} {opts_str} {glue::double_quote(local_url)} {glue::double_quote(nativefier_loc)}"
  )
  #cat(cmd,"\n")
  system(cmd)
  setwd(oldwd)
}

#' Create options string from keyword arguments
create_opts_str <- function(...) {
  opts_str <- ""
  opts <- list(...)
  for (i in seq_along(opts)) {
    opt <- opts[i]
    opt_name <- names(opt)
    if (is.null(opt_name)) stop("Missing option name")
    # no need to check if nchar(opt_name) < 1 - "" as a list key is not allowed
    opt_pref <- if (nchar(opt_name) == 1) "-" else "--"
    opt_value <- opt[[TRUE]]
    opt_value <- if (is.null(opt_value) || is.na(opt_value)) "" else
      glue::glue(" {glue::double_quote(opt_value)}") # always quote values
    opts_str <- glue::glue("{opts_str} {opt_pref}{opt_name}{opt_value}")
  }
  return(opts_str)
}
