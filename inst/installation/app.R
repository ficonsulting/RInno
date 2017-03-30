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

  if (file.exists(chrome) & user_browser == "chrome") {
    # First choice
    # Set the default browser option for shiny apps to chrome
    options(browser = chrome)

  } else if (file.exists(ff) & user_browser == "firefox") {
    # Second
    options(browser = ff)

  } else if (file.exists(ie) & user_browser == "ie") {
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

if (config$app_repo[[1]] != "none") {
  shiny::runApp(sprintf("./library/%s/app", config$appname), launch.browser = T)

} else {
  shiny::runApp("./", launch.browser = T)
}
