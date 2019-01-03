#' Creates an app config file, "utils/config.cfg"
#'
#' @inheritParams create_app
#' @param repo Default repository to install CRAN package dependencies. Defaults to \code{repo = "https://cran.rstudio.com"}.
#' @param error_log Name of error logging file. Contains start up errors from \emph{run.R}.
#' @param app_repo_url Repository address for continuous installations in the format \code{"https://bitbucket.org/username/repo"} (\code{repo = app_name}). Only Bitbucket and GitHub repositories are supported.
#' @param auth_user Bitbucket username. It is recommended to create a read-only account for each app.  Support for OAuth 2 and tokens is in the works.
#' @param auth_pw Bitbucket password matching the above username.
#' @param auth_token To install from a private Github repo, generate a personal access token (PAT) in \url{https://github.com/settings/tokens} and supply to this argument. This is safer than using a password because you can easily delete a PAT without affecting any others.
#' @param user_browser Character for the default browser. Options include "chrome", "firefox", and "ie."
#'
#' @author Jonathan M. Hill
#'
#' @return A json file, \emph{config.cfg}, in \code{app_dir}/utils.
#' @seealso \code{\link{create_app}}.
#' @export

create_config <- function(app_name, app_dir = getwd(),
  pkgs = c("jsonlite", "remotes", "magrittr"),
  pkgs_path = "library",
  remotes   = "none",
  repo = "https://cran.rstudio.com",
  error_log = "error.log", app_repo_url = "none", auth_user = "none",
  auth_pw = "none", auth_token = "none", user_browser = "electron") {

  # Reset defaults if empty
  reset_formals(create_config)

  # Check pkgs/locals class
  if (any(lapply(pkgs, class) != "character")) stop("`pkgs` must be a character vector.", call. = FALSE)

  # If app_dir/utils does not exist, create it
  if (!dir.exists(app_dir)) dir.create(app_dir)
  if (!dir.exists(file.path(app_dir, "utils"))) dir.create(file.path(app_dir, "utils"))

  # Make sure initial packages & shiny are included
  pkgs <- pkgs %>% standardize_pkgs()
  pkgs <- pkgs %>% add_pkgs(c("jsonlite", "shiny"))

  if (app_repo_url != "none") {
    # Fail early
    if (!any(grepl("bitbucket", app_repo_url), grepl("github", app_repo_url))) {
      stop(sprintf("%s is not a valid app_repo_url.", app_repo_url), call. = FALSE)
    }

    pkgs <- add_pkgs(pkgs, c("remotes", "httr"))

    # Set app_repo
    app_repo <- strsplit(app_repo_url, "org/|com/")[[1]][2]

    # Set host
    if (grepl("bitbucket.org", app_repo_url)) host <- "bitbucket"
    else host <- "github"

  } else {
    host     <- "none"
    app_repo <- "none"
  }

  # Check for a flexdashboard
  check_files <- list.files(app_dir, "rmd", full.names = TRUE, ignore.case = TRUE)

  if (length(check_files) != 0) {
    flex_file <- flexdashboard_check(check_files)

    if (length(flex_file) > 0) {
      # Make sure flexdashboard and rmarkdown are included in the dependency list
      pkgs <- pkgs  %>% add_pkgs(c("flexdashboard", "rmarkdown"))
      cat("This flexdashboard will be used:\n - ", flex_file, "\n")
    } else {
      flex_file <- "none"
    }
  } else {
    flex_file <- "none"
  }

  # Download packages and store them in pkgs_path
  if (interactive()) download_packages(app_dir, pkgs_path, pkgs, repo, remotes, auth_user, github_pat())

  jsonlite::write_json(
    list(
      appname      = app_name,
      pkgs         = list(
        pkgs_names = standardize_pkgs(pkgs),
        pkgs_loc   = file.path(pkgs_path, list.files(file.path(app_dir, pkgs_path)))
      ),
      logging      = error_log,
      host         = host,
      app_repo     = app_repo,
      auth_user    = auth_user,
      auth_pw      = auth_pw,
      auth_token   = auth_token,
      user_browser = tolower(user_browser),
      nativefier   = file.path("nativefier-app", list.files(file.path(app_dir, "nativefier-app"), pattern = ".exe", recursive = TRUE)),
      flex_file    = flex_file),
    file.path(app_dir, "utils/config.cfg"), pretty = T, auto_unbox = T)
}
