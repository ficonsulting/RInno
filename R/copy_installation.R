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

  utils <- file.path(app_dir, "utils")
  wsf     <- file.path(app_dir, "utils/wsf")
  wsf_js  <- file.path(app_dir, "utils/wsf/js")

  if (!dir.exists(utils)) dir.create(utils)
  if (!dir.exists(wsf)) dir.create(wsf)
  if (!dir.exists(wsf_js)) dir.create(wsf_js)

  install_files <- list.files(system.file("installation", package = "RInno"), full.names = T)

  # Files for each dir
  base_files   <- grep("iss$|wsf$|js$|R$", install_files, value = TRUE, invert = TRUE)
  wsf_files    <- grep("wsf$", install_files, value = TRUE)
  wsf_js_files <- grep("js$", install_files, value = TRUE)
  utils_files  <- grep(".R$", install_files, value = TRUE)

  # Return files
  file.copy(base_files,   app_dir)
  file.copy(wsf_files,    wsf)
  file.copy(wsf_js_files, wsf_js)
  file.copy(utils_files,  utils)
}
