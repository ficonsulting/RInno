#' Creates package dependency file, "packages.txt"
#'
#' @inheritParams create_app
#'
#' @return \emph{packages.txt} in \code{app_dir}.
#'
#' @author Jonathan M. Hill
#' @export

create_pkgs <- function(pkgs, app_dir) {

writeLines(c('# Package dependencies for the application that are loaded during
# start up.
#
# If not available, they will be installed in library/.  Custom source
# packages need to be installed manually.', pkgs),

  file.path(app_dir, 'packages.txt'))
}
