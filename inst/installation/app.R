# app launching code
config <- jsonlite::fromJSON("utils/config.cfg")
reg_paths <- jsonlite::fromJSON("utils/regpaths.json")

# This function is used to apply the web browser configuration and registry
# information on app start up. If a user does not have the user browser,
# their defult browser will be used.
find_browser <- function(
  app_name = config$appname,
  user_browser = config$user_browser,
  chrome = reg_paths$chrome,
  ff = reg_paths$ff,
  ie = reg_paths$ie) {

  if (user_browser == "chrome") {
    if (chrome != "none") {
      chrome <- gsub("\\\\", "/", file.path(chrome, "chrome.exe", fsep = "\\"))
      options(browser = chrome)
    }

  } else if (user_browser == "firefox") {
    if (ff != "none") {
      ff <- gsub("\\\\", "/", file.path(ff, "firefox.exe", fsep = "\\"))
      options(browser = ff)
    }

  } else if (user_browser == "ie") {
    if (ie != "none") {
      ie <- gsub("\\\\", "/", ie)
      options(browser = ie)
    }
  }
}

find_browser()

# If a repo has been provided, use the app in your package
if (config$app_repo[[1]] != "none") {
  app_path <- file.path(system.file(package = config$appname), "app")

  # flexdashboard
  if (config$flex_file != "none") {

    Sys.setenv(RSTUDIO_PANDOC = paste0(getwd(),"/library/pandoc/"))
    rmarkdown::run(file.path(app_path, config$flex_file),
                   shiny_args = list(host = '0.0.0.0', launch.browser = T))
  # Shiny
  } else {
    shiny::runApp(app_path, launch.browser = T)
  }

} else {
  # flexdashboard
  if (config$flex_file != "none") {
    Sys.setenv(RSTUDIO_PANDOC = paste0(getwd(),"/library/pandoc/"))
    rmarkdown::run(paste0("./", config$flex_file),
                   shiny_args = list(host = '0.0.0.0', launch.browser = T))
  # Shiny
  } else {
    shiny::runApp("./", launch.browser = T)
  }
}
