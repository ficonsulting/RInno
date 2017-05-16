#' Example app
#'
#' Creates a basic app to test in \code{wd/app}.
#'
#' @param wd Path to working directory.
#' @param type type of shiny framework for example.
#'
#' @return Shiny app example.
#'
#' @examples \dontrun{
#' example_app(getwd())
#' example_app(getwd(), type = "Flexdashboard")
#' }
#'
#' @author Jonathan M. Hill
#' @export

example_app <- function(wd, type = c("Shiny", "Flexdashboard")[1]) {
  if(type == "Shiny"){
    x <- list.files(system.file("app", package = "Rinno"), full.names = T)
  } else if (type == "Flexdashboard") {
    x <- list.files(system.file("flexdashboard_example", package = "Rinno"), full.names = T)
  } else {
    stop("Type of example app unknown, please choose between 'Shiny' or 'Flexdashboard'")
  }

  if (!dir.exists(file.path(wd, "app"))) dir.create(file.path(wd, "app"))

  x[file.copy(x, "app")]

  cat("Example:", file.path(wd, "app"))
}
