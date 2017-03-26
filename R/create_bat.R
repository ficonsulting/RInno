#' Creates app's batch file, "app_name.bat"
#'
#' This procedure creates a batch file that starts a shiny app using \code{wsf/run.wsf}.
#'
#' @inheritParams create_app
#'
#' @return BATCH file in \code{app_dir}
#'
#' @seealso \code{\link{create_app}}
#'
#' @author Jonathan M. Hill
#' @export

create_bat <- function(app_name, app_dir) {
  writeLines("wscript utils\\wsf\\run.wsf",
             file.path(app_dir, paste0(app_name, ".bat")))
}
