#' Creates deployment files and Inno Setup Script (ISS), "app_name.iss"
#'
#' This function manages installation and app start up. To accept all defaults, just provide \code{app_name}. After calling \code{create_app}, call \code{\link{compile_iss}} to create an installer in \code{dir_out}.
#'
#' Creates the following files in \code{app_dir}:
#' \itemize{
#'   \item Icons for installer and app, \emph{setup.ico} and \emph{default.ico} respectively.
#'   \item Files that manage app start up, \emph{package_manager.R} and \emph{app.R}.
#'   \item First/last page of the installer, \emph{infobefore.txt} and \emph{infoafter.txt}.
#'   \item Batch support files, \emph{wsf/run.wsf}, \emph{wsf/js/run.js}, \emph{wsf/js/json2.js}, \emph{wsf/js/JSON.minify.js}.
#'   \item List of package dependencies from \code{pkgs}, \emph{packages.txt}.
#'   \item A configuration file, \emph{config.cfg}. See \code{\link{create_config}} for details.
#'   \item A batch file, \emph{app_name.bat}. See \code{\link{create_bat}} for details.
#'   \item An Inno Setup Script, \emph{app_name.iss}.
#' }
#'
#' @param app_name The name of the app being installed. It will be displayed throughout the installer and uninstaller in window titles, wizard pages, and dialog boxes. See \href{http://www.jrsoftware.org/ishelp/topic_setup_appname.htm}{[Setup]:AppName} for details. For continuous deployments, \code{app_name} is used to check for an R package of the same name, and update it. The Deployment vignette has more details.
#' @param app_dir Shiny app's directory, defaults to \code{getwd()}.
#' @param dir_out Installer's directory. A sub-directory of \code{app_dir}, which will be created if it does not already exist. Defaults to 'RInno_installer'.
#' @param pkgs String vector of the shiny app's package dependencies.
#' @param include_R To include R in the installer, \code{include_R = TRUE}. This will include the version of R specified by \code{R_version} in your installer. The installer will check each user's registry for that version of R, and only install it if that check returns FALSE.
#' @param R_version R version to use, defaults to: \code{paste0(R.version$major, '.', R.version$minor)}.
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
#'   pkgs      = c('jsonlite', 'shiny', 'magrittr', 'xkcd'),
#'   include_R = TRUE,   # Download R and install it with the app
#'   R_version = 2.2.1,  # Old version of R
#'   privilege = 'high', # Admin only installation
#'   default_dir = 'pf') # Program Files
#' }
#' @inherit setup seealso
#' @author Jonathan M. Hill
#' @export
create_app <- function(app_name,
  app_dir    = getwd(),
  dir_out   = "RInno_installer",
  pkgs      = c("jsonlite", "shiny", "magrittr"),
  include_R = F,
  R_version = paste0(R.version$major, ".", R.version$minor),
  ...) {

  # To capture arguments for other function calls
  dots <- list(...)

  # Copy deployment scripts
  copy_deployment(app_dir)

  if (include_R) get_R(app_dir, R_version)

  # Create batch file
  create_bat(app_name, app_dir)

  # Create app config file
  create_config(app_name, R_version, app_dir,
    repo         = dots$repo,
    error_log    = dots$error_log,
    app_repo_url = dots$app_repo_url,
    auth_user    = dots$auth_user,
    auth_pw      = dots$auth_pw)

  # Create package dependency list
  create_pkgs(pkgs, app_dir)

  # Build the iss script
  iss <- start_iss(app_name)

  # C-like directives
  iss2 <- directives(iss, include_R, R_version,
    app_version = dots$app_version, publisher = dots$publisher,
    main_url = dots$main_url)

  # Setup Section
  iss3 <- setup(iss2, dir_out,
    app_version = dots$app_version,
    default_dir = dots$default_dir,
    privilege = dots$privilege,
    info_before = dots$info_before,
    info_after = dots$info_after,
    setup_icon = dots$setup_icon,
    inst_pw = dots$inst_pw,
    license_file = dots$license_file,
    pub_url = dots$pub_url,
    sup_url = dots$sup_url,
    upd_url = dots$upd_url)

  # Languages Section
  iss4 <- languages(iss3)

  # Tasks Section
  iss5 <- tasks(iss4, desktop_icon = dots$desktop_icon)

  # Files Section
  iss6 <- files(iss5, app_dir, file_list = dots$file_list)

  # Icons Section
  iss7 <- icons(iss6, app_desc = dots$app_desc,
        app_icon = dots$app_icon,
        prog_menu_icon = dots$prog_menu_icon,
        desktop_icon = dots$desktop_icon)

  # Execution & Pascal code to check registry during installation
  iss8 <- run(iss7)
  iss9 <- code(iss8)

  # Write the Inno Setup script
  writeLines(iss9, file.path(app_dir, paste0(app_name, ".iss")))
}
