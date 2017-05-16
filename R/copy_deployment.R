#' Default Deployment Files
#'
#' This function moves files stored in \code{system.file('deployment', package = 'RInno')} to \code{app_dir}:
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

copy_deployment <- function(app_dir, flex_file = F) {

  # Set option for location of app
  options("RInno.app_dir"   = app_dir)

  wsf <- file.path(app_dir, "wsf")
  wsf_js <- file.path(app_dir, "wsf/js")

  if (!dir.exists(wsf)) dir.create(wsf)
  if (!dir.exists(wsf_js)) dir.create(file.path(wsf_js))

  deploy_files <- list.files(system.file("deployment", package = "RInno"),
    full.names = T)

  # Return files
  file.copy(deploy_files[!grepl("iss$|wsf$|js$", deploy_files)], app_dir)

  # rewrite shiny launch code line 47 & 50 with flexdashboard launcher
  if(flex_file != F){
    app_launch_file <- readLines(file.path(app_dir, "app.R"))

    shiny_launch_code_line <- grep("shiny::runApp", app_launch_file)

    for(i in shiny_launch_code_line){
      app_launch_file[i] <- paste0("rmarkdown::run(file.path('", normalizePath(flex_file, winslash = "/"),"'), shiny_args = list(host = '0.0.0.0', launch.browser = T))")
    }
    writeLines(app_launch_file, file.path(app_dir, "app.R"))
  }

  file.copy(deploy_files[grepl("wsf$", deploy_files)], file.path(wsf))
  file.copy(deploy_files[grepl("js$", deploy_files)], file.path(wsf_js))
}
