#' Creates installation files and Inno Setup Script (ISS), "app_name.iss"
#'
#' This function manages installation and app start up. To accept all defaults, just provide \code{app_name}. After calling \code{create_app}, call \code{\link{compile_iss}} to create an installer in \code{dir_out}.
#'
#' Creates the following files in \code{app_dir}:
#' \itemize{
#'   \item Icons for installer and app, \emph{setup.ico} and \emph{default.ico} respectively.
#'   \item Files that manage app start up, \emph{utils/package_manager.R}, \emph{utils/ensure.R}, and \emph{utils/launch_app.R}.
#'   \item First/last page of the installer, \emph{infobefore.txt} and \emph{infoafter.txt}.
#'   \item Batch support files, \emph{utils/wsf/run.wsf}, \emph{utils/wsf/js/run.js}, \emph{utils/wsf/js/json2.js}, \emph{utils/wsf/js/JSON.minify.js}.
#'   \item A configuration file, \emph{config.cfg}. See \code{\link{create_config}} for details.
#'   \item A batch file, \emph{app_name.bat}. See \code{\link{create_bat}} for details.
#'   \item An Inno Setup Script, \emph{app_name.iss}.
#' }
#'
#' @param app_name The name of the app. It will be displayed throughout the installer's window titles, wizard pages, and dialog boxes. See \href{http://www.jrsoftware.org/ishelp/topic_setup_appname.htm}{[Setup]:AppName} for details. For continuous installations, \code{app_name} is used to check for an R package of the same name, and update it. The Continuous Installation vignette has more details.
#' @param app_dir Development app's directory, defaults to \code{getwd()}.
#' @param app_port The port number on which the app is broadcasted, defaults to 1984.
#' @param dir_out Installer's directory. A sub-directory of \code{app_dir}, which will be created if it does not exist. Defaults to 'RInno_installer'.
#' @param pkgs Character vector of package dependencies. Remote development versions are supported via \code{remotes}. \code{pkgs} are downloaded into \code{file.path(app_dir, pkgs_path)} as Windows binary packages (.zip). If you build binary packages and store them there before calling \code{create_app}, they will be included as well.
#' @param pkgs_path Default location inside the app working directory to install package dependencies This defaults to \code{pkgs_path = "bin"}
#' @param remotes Character vector of GitHub repository addresses in the format \code{username/repo[/subdir][\@ref|#pull]} for GitHub package dependencies.
#' @param locals Character vector of local package dependencies. Deprecated as of v1.0.0. Use \code{pkgs} instead.
#' @param include_R To include R in the installer, \code{include_R = TRUE}. The version of R specified by \code{R_version} is used. The installer will check each user's registry and only install R if necessary.
#' @param R_version R version to use. Supports inequalities. Defaults to: \code{paste0(">=", R.version$major, '.', R.version$minor)}.
#' @param include_Pandoc To include Pandoc in the installer, \code{include_Pandoc = TRUE}. If installing a flexdashboard app, some users may need a copy of Pandoc. The installer will check the user's registry for the version of Pandoc specified in \code{Pandoc_version} and only install it if necessary.
#' @param Pandoc_version Pandoc version to use, defaults to: \link[rmarkdown]{pandoc_available}.
#' @param include_Chrome To include Chrome in the installer, \code{include_Chrome = TRUE}. If you would like to use Chrome's app mode, it is no longer supported by Google :(.
#' @param include_Rtools To include Rtools in the installer, \code{include_Rtools = TRUE}. For some packages to build properly, you may need to include Rtools.
#' @param Rtools_version Rtools version to include. For more information, see \href{https://cran.r-project.org/bin/windows/Rtools/}{Building R for Windows}.
#' @param overwrite Logical. Should existing installation files be overwritten? See \code{\link{copy_installation}} for details.
#' @param force_nativefier Boolean. Defaults to true and re-builds UI. If false, the UI is not rebuilt.
#' @param nativefier_opts Character vector. Extra options to pass to nativefier when \code{user_browser = "electron"}. Each string in the vector should be a valid nativefier command. For example, \code{c('--no-overwrite', '--conceal', '--show-menu-bar')}. For more information, \code{system("nativefier --help")}.
#'
#' @param ... Arguments passed on to \code{setup_section}, \code{files_section}, \code{directives_section}, \code{icons_section}, \code{languages_section}, \code{code_section}, \code{tasks_section}, and \code{run_section}.
#' @inheritParams create_config
#' @examples
#' \dontrun{
#'
#' create_app('myapp')
#'
#' create_app(
#'   app_name     = 'My AppName',
#'   app_dir      = 'My/app/path',
#'   dir_out      = 'wizard',
#'   pkgs         = c('jsonlite', 'shiny', 'magrittr', 'xkcd'),
#'   include_R    = TRUE,   # Download R and install it with the app
#'   R_version    = "2.2.1",  # Old version of R
#'   privilege    = 'high', # Admin only installation
#'   default_dir  = 'pf') # Program Files
#' }
#' @inherit setup_section seealso
#' @author Jonathan M. Hill and Hanjo Odendaal
#' @export
create_app <- function(
  app_name         = "myapp",
  app_dir          = getwd(),
  app_port         = 1984,
  dir_out          = "RInno_installer",
  pkgs             = c("jsonlite", "shiny", "magrittr"),
  pkgs_path        = "bin",
  repo             = "https://cran.rstudio.com",
  remotes          = "none",
  locals           = NULL,
  app_repo_url     = "none",
  auth_user        = "none",
  auth_pw          = "none",
  auth_token       = github_pat(),
  user_browser     = "electron",
  include_R        = FALSE,
  include_Pandoc   = FALSE,
  include_Chrome   = FALSE,
  include_Rtools   = FALSE,
  R_version        = paste0(">=", R.version$major, ".", R.version$minor),
  Pandoc_version   = rmarkdown::pandoc_version(),
  Rtools_version   = "3.5",
  overwrite        = TRUE,
  force_nativefier = TRUE,
  nativefier_opts  = c(),
  ...) {

  # To capture arguments for other function calls
  dots <- list(...)

  # 1.0.0 deprecation messages
  if (!is.null(locals)) {
    warning("locals is deprecated. Please use pkgs instead.", call. = FALSE)
    pkgs <- pkgs %>% standardize_pkgs %>% add_pkgs(locals)
  }
  if (user_browser != "electron") {
    warning(glue::glue("user_browser = {glue::double_quote(user_browser)} will be deprecated in the next release. Please use user_browser = \"electron\" in the future."), call. = FALSE)
  }
  if (include_Chrome) {
    warning("include_Chrome will be deprecated in the next release. Please use user_browser = \"electron\"", call. = FALSE)
  }
  if (!is.null(dots$ping_site)) {
    warning("ping_site is deprecated in favor of self-contained dependency management in the .exe.", call. = FALSE)
  }

  # If app_name is not a character, exit
  if (class(app_name) != "character") stop("app_name must be a character.", call. = FALSE)

  # If dir_out is not a character, exit
  if (class(dir_out) != "character") stop("dir_out must be a character.", call. = FALSE)

  # If not TRUE/FALSE, exit
  logicals <- c(
    "include_Chrome" = class(include_Chrome),
    "include_Pandoc" = class(include_Pandoc),
    "include_R" = class(include_R),
    "include_Rtools" = class(include_Rtools),
    "overwrite" = class(overwrite))
  failed_logicals <- !logicals %in% "logical"

  if (any(failed_logicals)) {
    stop(glue::glue("{names(logicals[which(failed_logicals)])} must be TRUE/FALSE."), call. = F)
  }

  # If app_dir does not exist create it
  if (!dir.exists(app_dir)) dir.create(app_dir)

  # If R_version is not valid, exit
  R_version <- sanitize_R_version(R_version)

  # Copy installation scripts
  copy_installation(app_dir, overwrite)

  # Include separate installers for R, Pandoc, and Chrome
  if (include_R) get_R(app_dir, R_version)
  if (include_Pandoc) get_Pandoc(app_dir, Pandoc_version)
  if (include_Chrome) get_Chrome(app_dir)
  if (include_Rtools) get_Rtools(app_dir, Rtools_version, R_version)

  # nativefy the app
  if (user_browser == "electron" && interactive()) {
    if (force_nativefier) {
      nativefy_app(app_name, app_dir, nativefier_opts, app_icon = dots$app_icon, app_port = app_port)
    } else {
      if (!dir.exists(file.path(app_dir, "nativefier-app")))
        nativefy_app(app_name, app_dir, nativefier_opts, app_icon = dots$app_icon, app_port = app_port)
      cat("\nUsing previously built electron app...\n")
    }
  }

  # # electron app
  # if (user_browser == "electron" && interactive()) {
  #   if (force_electron) {
  #     electron_app(app_name, app_dir, nativefier_opts, app_icon = dots$app_icon)
  #   } else {
  #     if (!dir.exists(file.path(app_dir, "electron-app")))
  #       electron_app(app_name, app_dir, nativefier_opts, app_icon = dots$app_icon)
  #     cat("\nUsing previously built electron app...\n")
  #   }
  # }

  # Create batch file
  create_bat(app_name, app_dir)

  # Create app config file
  create_config(app_name, app_dir,
                pkgs = pkgs, pkgs_path = pkgs_path, remotes = remotes,
                repo = repo, error_log = dots$error_log,
                app_repo_url = app_repo_url, auth_user = auth_user,
                auth_pw = auth_pw, auth_token = auth_token,
                user_browser = user_browser)

  # Build the iss script
  start_iss(app_name) %>%

  # C-like directives
  directives_section(include_R, R_version, include_Pandoc, Pandoc_version,
    include_Chrome, include_Rtools, Rtools_version,
    app_version = dots$app_version, publisher = dots$publisher,
    main_url = dots$main_url) %>%

  # Setup Section
  setup_section(app_dir, dir_out, app_version = dots$app_version,
    default_dir = dots$default_dir, privilege = dots$privilege,
    info_before = dots$info_before, info_after = dots$info_after,
    setup_icon = dots$setup_icon, inst_pw = dots$inst_pw,
    license_file = dots$license_file, pub_url = dots$pub_url,
    sup_url = dots$sup_url, upd_url = dots$upd_url) %>%

  # Languages Section
  languages_section %>%

  # Tasks Section
  tasks_section(desktop_icon = dots$desktop_icon) %>%

  # Icons Section
  icons_section(app_dir, app_desc = dots$app_desc, app_icon = dots$app_icon,
    prog_menu_icon = dots$prog_menu_icon, desktop_icon = dots$desktop_icon) %>%

  # Files Section
  files_section(app_name, app_dir, user_browser, file_list = dots$file_list) %>%


  # Execution & Pascal code to check registry during installation
  run_section(dots$R_flags) %>%
    code_section(R_version) %>%

  # Write the Inno Setup script
  writeLines(file.path(app_dir, paste0(app_name, ".iss")))

  # Clean up
  check_app(app_dir, pkgs_path)
}
