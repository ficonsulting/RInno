# capture the current working directory
# set the package search path to the app specific library
appwd <- getwd()
applibpath <- file.path(appwd, "library")

message("library path:\n", paste("...", applibpath, "\n"))
message("working path:\n", paste("...", appwd, "\n"))
message("interactive R session:\n", paste("...", interactive(), "\n"))

# Load functions to ensure software dependencies and check the internet
source("utils/ensure.R")

# Create app/library if it doesn't exist (e.g. first run)
# Initialize RInno
if (!dir.exists(applibpath)) {
  pb <- winProgressBar(
    title = "Starting RInno ...",
    label = "Initializing ...")

  dir.create(applibpath)
  init_pkgs <- c("jsonlite")

  for (i in seq_along(init_pkgs)) {
    setWinProgressBar(pb, value = i / (length(init_pkgs) + 1),
      label = sprintf("Loading package - %s", init_pkgs[i]))
    pkg <- list.files(appwd, paste0(init_pkgs[i], ".*zip$"), full.names = TRUE, recursive = TRUE)
    install.packages(pkgs = pkg, lib = applibpath, repos = NULL, type = "win.binary")
  }
  close(pb)
}

# Add app/library to R's library search path
.libPaths(c(applibpath, .libPaths()))

# Read the application config
library("jsonlite", character.only = TRUE)
config <- jsonlite::fromJSON(file.path(appwd, "utils/config.cfg"))

# Package dependency list
pkgs_loc <- config$pkgs$pkgs_loc; pkgs_names <- config$pkgs$pkgs_names

# Provide some initial status updates
pb <- winProgressBar(
  title = sprintf("Starting %s ...", config$appname),
  label = "Initializing ...")

# Use tryCatch to display error messages in config$logging$filename
appexit_msg <- tryCatch({

  # ensure all package dependencies are installed
  message("ensuring packages: ", paste(pkgs_names, collapse = ", "))
  setWinProgressBar(pb, 0, label = "Ensuring package dependencies ...")

  ensure(pkgs_loc)

  for (i in seq_along(pkgs_names)) {
    setWinProgressBar(pb,
      value = i / (length(pkgs_names) + 1),
      label = sprintf("Loading package - %s", pkgs_names[i]))

    library(pkgs_names[i], character.only = TRUE)
  }

  # If an app repository has been provided, install the app from there
  if (config$app_repo[[1]] != "none") {
    source("utils/get_app_from_app_url.R")
  }

  setWinProgressBar(pb, 1.00, label = "Starting application")
  close(pb)

  # Start the app
  source(file.path(appwd, "utils/launch_app.R"))

  "application terminated normally"
},
error = function(e) {
  msg <- sprintf("Startup failed with error(s):\n\n%s", e$message)
  tcltk::tk_messageBox(
    type = "ok",
    message = msg,
    icon = "error")

  msg
},
finally = {
  close(pb)
})

message(appexit_msg)
