#' Creates installation files and Inno Setup Script (ISS), "app_name.iss"
#'
#' This function manages installation and app start up. To accept all defaults, just provide \code{app_name}. After calling \code{create_app}, call \code{\link{compile_iss}} to create an installer in \code{dir_out}.
#'
#' Creates the following files in \code{app_dir}:
#' \itemize{
#'   \item Icons for installer and app, \emph{setup.ico} and \emph{default.ico} respectively.
#'   \item Files that manage app start up, \emph{utils/package_manager.R} and \emph{utils/app.R}.
#'   \item First/last page of the installer, \emph{infobefore.txt} and \emph{infoafter.txt}.
#'   \item Batch support files, \emph{utils/wsf/run.wsf}, \emph{utils/wsf/js/run.js}, \emph{utils/wsf/js/json2.js}, \emph{utils/wsf/js/JSON.minify.js}.
#'   \item A configuration file, \emph{config.cfg}. See \code{\link{create_config}} for details.
#'   \item A batch file, \emph{app_name.bat}. See \code{\link{create_bat}} for details.
#'   \item An Inno Setup Script, \emph{app_name.iss}.
#' }
#'
#' @param app_name The name of the app being installed. It will be displayed throughout the installer's window titles, wizard pages, and dialog boxes. See \href{http://www.jrsoftware.org/ishelp/topic_setup_appname.htm}{[Setup]:AppName} for details. For continuous installations, \code{app_name} is used to check for an R package of the same name, and update it. The Continuous Installation vignette has more details.
#' @param app_dir Shiny app's directory, defaults to \code{getwd()}.
#' @param dir_out Installer's directory. A sub-directory of \code{app_dir}, which will be created if it does not already exist. Defaults to 'RInno_installer'.
#' @param pkgs String vector of the shiny app's default repo package dependencies. Also supports package version numbers. See \code{\link{create_config}} for how to change the default repo.
#' @param local_pkgs String vector of the shiny app's local package dependencies.  Also supports package version numbers.  See \code{\link{create_config}} for how to change the local package location.
#' @param include_R To include R in the installer, \code{include_R = TRUE}. This will include the version of R specified by \code{R_version} in your installer. The installer will check each user's registry for that version of R, and only install it if necessary.
#' @param include_Pandoc To include Pandoc in the installer, \code{include_Pandoc = TRUE}. If installing a flexdashboard app, some users may need a copy of Pandoc. Similar to including R, the installer will check the user's registry for the version of Pandoc returned by \code{\link[rmarkdown]{pandoc_version}} and only install it if necessary.
#' @param include_Chrome To include Chrome in the installer, \code{include_Chrome = TRUE}. If you would like to use Chrome's app mode, this option includes a copy of Chrome for users that do not have it installed yet.
#' @param R_version R version to use, defaults to: \code{paste0(R.version$major, '.', R.version$minor)}.
#' @param Pandoc_version Pandoc version to use, defaults to: \code{\link[rmarkdown]{pandoc_version}}.
#' @inheritDotParams setup -iss -dir_out
#'
#' @examples
#' \dontrun{
#'
#' create_app('myapp')
#'
#' create_app(
#'   app_name  = 'My AppName',
#'   app_dir    = 'My/app/path',
#'   dir_out   = 'wizard',
#'   pkgs      = c('jsonlite', shiny = '1.0.5', magrittr = '1.5', 'xkcd'),
#'   local_pkgs = c('my_pkg'),
#'   include_R = TRUE,   # Download R and install it with the app
#'   R_version = 2.2.1,  # Old version of R
#'   privilege = 'high', # Admin only installation
#'   default_dir = 'pf') # Program Files
#' }
#' @inherit setup seealso
#' @author Jonathan M. Hill and Hanjo Odendaal
#' @export
create_app <- function(app_name,
  app_dir   = getwd(),
  dir_out   = "RInno_installer",
  pkgs      = c("jsonlite", "shiny", "magrittr"),
  local_pkgs = c(),
  include_R = FALSE,
  include_Pandoc = FALSE,
  include_Chrome = FALSE,
  R_version = paste0(R.version$major, ".", R.version$minor),
  Pandoc_version = rmarkdown::pandoc_version(),
  ...) {

  # To capture arguments for other function calls
  dots <- list(...)

  # If app_name is not a character, exit
  if (class(app_name) != "character") stop("app_name must be a character.")

  # If dir_out is not a character, exit
  if (class(dir_out) != "character") stop("dir_out must be a character.")

  # If not TRUE/FALSE, exit
  include_logicals <- c(
    "include_Chrome" = class(include_Chrome),
    "include_Pandoc" = class(include_Pandoc),
    "include_R" = class(include_R))
  failed_logical <- !include_logicals %in% "logical"

  if (any(failed_logical)) {
    stop(glue::glue("{names(include_logicals[which(failed_logical)])} must be TRUE/FALSE."))
  }

  # If app_dir does not exist create it
  if (!dir.exists(app_dir)) dir.create(app_dir)

  # If R_version is not valid, exit
  if (any(length(strsplit(R_version, "\\.")[[1]]) != 3, !grepl("[1-3]\\.[0-9]+\\.[0-9]+", R_version))) {
    stop("R_version is not valid.")
  }

  # Copy installation scripts
  copy_installation(app_dir)

  # Include separate installers for R, Pandoc, and Chrome if necessary
  if (include_R) get_R(app_dir, R_version)
  if (include_Pandoc) get_Pandoc(app_dir, Pandoc_version)
  if (include_Chrome) get_Chrome(app_dir)

  # Create batch file
  create_bat(app_name, app_dir)

  # Create app config file
  create_config(app_name, app_dir, pkgs, local_pkgs,
    remotes = dots$remotes, repo = dots$repo, error_log = dots$error_log,
    app_repo_url = dots$app_repo_url, auth_user = dots$auth_user,
    auth_pw = dots$auth_pw, auth_token = dots$auth_token,
    user_browser = dots$user_browser)

  # Build the iss script
  iss <- start_iss(app_name)

  # C-like directives
  iss <- directives(iss, include_R, R_version, include_Pandoc, Pandoc_version,
    include_Chrome, app_version = dots$app_version, publisher = dots$publisher,
    main_url = dots$main_url)

  # Setup Section
  iss <- setup(iss, app_dir, dir_out, app_version = dots$app_version,
    default_dir = dots$default_dir, privilege = dots$privilege,
    info_before = dots$info_before, info_after = dots$info_after,
    setup_icon = dots$setup_icon, inst_pw = dots$inst_pw,
    license_file = dots$license_file, pub_url = dots$pub_url,
    sup_url = dots$sup_url, upd_url = dots$upd_url)

  # Languages Section
  iss <- languages(iss)

  # Tasks Section
  iss <- tasks(iss, desktop_icon = dots$desktop_icon)

  # Icons Section
  iss <- icons(iss, app_dir, app_desc = dots$app_desc, app_icon = dots$app_icon,
    prog_menu_icon = dots$prog_menu_icon, desktop_icon = dots$desktop_icon)

  # Files Section
  iss <- files(iss, app_dir, file_list = dots$file_list)

  # Execution & Pascal code to check registry during installation
  iss <- run(iss, dots$R_flags); iss <- code(iss)

  # Write the Inno Setup script
  writeLines(iss, file.path(app_dir, paste0(app_name, ".iss")))
}
