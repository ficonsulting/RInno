#' Start ISS
#'
#' Chain \code{\link{directives}} against this function to start building custom
#' installers.
#'
#' @inheritParams create_app
#'
#' @examples
#' \dontrun{
#' start_iss('myapp') %>%
#'   directives(include_R = FALSE, R_version = '3.3.2')
#' }
#'
#' @return \code{app_name} and set \code{options('Rinno.app_name' = app_name)}
#'
#' @seealso \code{\link{directives}}.
#' @author Jonathan M. Hill
#' @export
start_iss <- function(app_name) {
  options("RInno.app_name" = app_name)

  app_name
}
