#' Example app
#'
#' Creates a basic app to test in \code{wd/app}.
#'
#' @param wd Path to working directory.
#'
#' @return Shiny app example.
#'
#' @examples \dontrun{
#' example_app(getwd())
#' }
#'
#' @author Jonathan M. Hill
#' @export

example_app <- function(wd) {
  x <- list.files(system.file("app", package = "Rinno"), full.names = T)

  if (!dir.exists(file.path(wd, "app"))) dir.create(file.path(wd, "app"))

  x[file.copy(x, "app")]

  cat("Example:", file.path(wd, "app"))
}
