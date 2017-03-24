#' Default installation files
#'
#' This function moves files stored in \code{system.file('installation', package = 'RInno')} to \code{app_dir}:
#' \itemize{
#'   \item Icons for installer and app, \emph{setup.ico} and \emph{default.ico}.
#'   \item Files that manage app start up, \emph{package_manager.R} and \emph{app.R}.
#'   \item First/last page of the installation wizard, \emph{infobefore.txt} and \emph{infoafter.txt}.
#'   \item Batch support files, \emph{wsf/run.wsf}, \emph{wsf/js/run.js}, \emph{wsf/js/json2.js}, and \emph{wsf/js/JSON.minify.js}.
#' }
#'
#' @inheritParams create_app
#'
#' @author Jonathan M. Hill
#'
#' @seealso \code{\link{create_app}}
#'
#' @export

copy_installation <- function(app_dir) {

  # Set option for location of app
  options("RInno.app_dir"   = app_dir)

  wsf     <- file.path(app_dir, "wsf")
  wsf_js  <- file.path(app_dir, "wsf/js")
  utils <- file.path(app_dir, "utils")

  if (!dir.exists(wsf)) dir.create(wsf)
  if (!dir.exists(wsf_js)) dir.create(file.path(wsf_js))
  if (!dir.exists(utils)) dir.create(file.path(utils))

  install_files <- list.files(system.file("installation", package = "RInno"),
    full.names = T)

  # Return files
  file.copy(install_files[!grepl("iss$|wsf$|js$", install_files)], app_dir)
  file.copy(install_files[grepl("wsf$", install_files)], file.path(wsf))
  file.copy(install_files[grepl("js$", install_files)], file.path(wsf_js))
  file.copy(install_files[basename(install_files) %in% c("ensure.R", "get_app_from_app_url.R")], utils)
}
