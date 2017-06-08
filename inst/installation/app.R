# app launching code
config <- jsonlite::fromJSON("utils/config.cfg")

find_browser <- function(
  app_name = config$appname,
  user_browser = config$user_browser) {

  progs  <- c(list.dirs("C:/Program Files", T, F),
           list.dirs("C:/Program Files (x86)", T, F))

  chrome <- file.path(progs[grep("Google", progs)],
                      "Chrome/Application/Chrome.exe")

  ff     <- file.path(progs[grep("Mozilla Firefox", progs)],
                      "firefox.exe")

  ie     <- file.path(progs[grep("Internet Explorer", progs)][1],
                      "iexplore.exe")

  if (length(chrome) > 0 & user_browser == "chrome") {
    # First choice
    # Set the default browser option for shiny apps to chrome
    options(browser = chrome)

  } else if (length(ff) > 0 & user_browser == "firefox") {
    # Second
    options(browser = ff)

  } else if (length(ie) > 0 & user_browser == "ie") {
    # Not ideal
    options(browser = ie)

  } else if (file.exists(config$browser)) {
    # Set the default browser option for shiny apps to manual_browser, so user
    # doesn't get prompted again.
    options(browser = config$browser)

  } else {
    # Ask the user to find their browser
    manual_browser <- choose.files(
      default = Sys.getenv("ProgramW6432"),
      caption = sprintf("%s cannot find your browser. Please select its .exe file.", app_name))

    # Store the result
    config$browser <- manual_browser
    jsonlite::write_json(config, "utils/config.cfg")

    # Set the default browser option for shiny apps
    options(browser = manual_browser)
  }
}

find_browser()

# If a repo has been provided, use the app in your package
if (config$app_repo[[1]] != "none") {
  app_path <- file.path(system.file(package = config$appname), "app")

  # flexdashboard
  if (config$flex_file != "none") {
    rmarkdown::run(file.path(app_path, config$flex_file),
                   shiny_args = list(host = '0.0.0.0', launch.browser = T))
  # Shiny
  } else {
    shiny::runApp(app_path, launch.browser = T)
  }

} else {
  # flexdashboard
  if (config$flex_file != "none") {
    rmarkdown::run(paste0("./", config$flex_file),
                   shiny_args = list(host = '0.0.0.0', launch.browser = T))
  # Shiny
  } else {
    shiny::runApp("./", launch.browser = T)
  }
}
