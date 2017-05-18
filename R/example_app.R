#' Example app
#'
#' Creates a basic app to test in \code{wd/app_dir}.
#'
#' @param wd Path to working directory. Defaults to \code{getwd()}.
#' @param app_dir Shiny app's directory. Defaults to "app".
#' @param type "Shiny" or "flexdashboard". Defaults to "Shiny".
#'
#' @return Shiny app example.
#'
#' @examples \dontrun{
#' example_app(getwd())
#' }
#'
#' @author Jonathan M. Hill
#' @export

example_app <- function(app_dir = "app", wd = getwd(), type = "Shiny") {

  if (grepl("Shiny", type, TRUE)) {
    x <- list.files(system.file("app", package = "RInno"), full.names = T)
  } else if (grepl("flex", type, TRUE)) {
    x <- list.files(system.file("flexdashboard_example", package = "RInno"), full.names = T)
  } else {
    stop("type should be 'Shiny' or 'Flexdashboard'.")
  }

  if (!dir.exists(file.path(wd, app_dir))) dir.create(file.path(wd, app_dir))

  x[file.copy(x, app_dir)]

  cat("Example:", file.path(wd, app_dir))
}
