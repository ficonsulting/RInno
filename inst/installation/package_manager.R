# capture the current working directory
# set the package search path to the app specific library
appwd <- getwd()
applibpath <- file.path(appwd, "library")

# Create app/library if it doesn't exist (e.g. first run)
# Initialize RInno
if (!dir.exists(applibpath)) {
  dir.create(applibpath)
  chooseCRANmirror(graphics = F, ind = 28)

  pb <- winProgressBar(
    title = "Starting RInno Deployment ...",
    label = "Initializing ...")

  init_pkgs <- c("jsonlite", "devtools", "httr")

  for (i in seq_along(init_pkgs)) {
    setWinProgressBar(pb, value = i / (length(init_pkgs) + 1),
      label = sprintf("Loading package - %s", init_pkgs[i]))
    install.packages(init_pkgs[i], applibpath)
  }
  close(pb)
}

.libPaths(c(applibpath, .libPaths()))

message("library paths:\n", paste0("... ", .libPaths(), collapse = "\n"))
message("working path:\n", paste("...", appwd))

# Read the application config
library("jsonlite", character.only = TRUE)
library("devtools", character.only = TRUE)
library("httr", character.only = TRUE)
config <- jsonlite::fromJSON(file.path(appwd, "utils/config.cfg"))

# Package dependency list
pkgs <- config$pkgs$pkgs; remotes <- config$remotes

# Provide some initialization status updates
pb <- winProgressBar(
  title = sprintf("Starting %s ...", config$appname),
  label = "Initializing ...")

# If an app repository has been provided, install the app from there
if (config$app_repo[[1]] != "none") {
  source("utils/get_app_from_app_url.R")
}

# Load functions to ensure software dependencies
source("utils/ensure.R")

# Use tryCatch to display error messages in config$logging$filename
appexit_msg <- tryCatch({

  # ensure all package dependencies are installed
  message("ensuring packages: ", paste(pkgs, collapse = ", "))
  setWinProgressBar(pb, 0, label = "Ensuring package dependencies ...")
  ._ <- lapply(pkgs, ensure, repo = config$pkgs$cran)
  if (remotes[1] != "none") {
    setWinProgressBar(pb, 0, label = "Ensuring GitHub package dependencies ...")
    ._ <- lapply(remotes, ensure_remotes)
  }

  for (i in seq_along(pkgs)) {
    setWinProgressBar(pb,
      value = i / (length(pkgs) + 1),
      label = sprintf("Loading package - %s", pkgs[i]))

    library(pkgs[i], character.only = TRUE)
  }

  setWinProgressBar(pb, 1.00, label = "Starting application")
  close(pb)

  # App is launched in the system default browser (if FF or Chrome, should work
  # fine, IE needs to be >= 10)
  source(file.path(appwd, "utils/app.R"))

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
