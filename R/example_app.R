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
#' # Shiny example
#' example_app()
#' create_app("myapp", "app")
#'
#' # Flexdashboard example
#' example_app(type = "flexdashboard")
#' create_app("myapp", "app")
#' }
#'
#' @author Jonathan M. Hill
#' @export

example_app <- function(app_dir = "app", wd = getwd(), type = "Shiny") {

  if (!dir.exists(file.path(wd, app_dir))) dir.create(file.path(wd, app_dir))

  if (grepl("Shiny", type, TRUE)) {

    data_dir <- file.path(wd, app_dir, "data")
    www_dir <- file.path(wd, app_dir, "www")
    html_dir <- file.path(wd, app_dir, "html")
    local_dir <- file.path(wd, app_dir, "local")

    dir.create(data_dir)
    dir.create(www_dir)
    dir.create(html_dir)
    dir.create(local_dir)

    app_files <- list.files(system.file("app", package = "RInno"), full.names = TRUE, pattern = "*.R")
    data_files <- list.files(system.file("app/data", package = "RInno"), full.names = TRUE)
    www_files <- list.files(system.file("app/www", package = "RInno"), full.names = TRUE)
    html_files <- list.files(system.file("app/html", package = "RInno"), full.names = TRUE)
    local_files <- list.files(system.file("app/local", package = "RInno"), full.names = TRUE)

    file.copy(app_files, app_dir)
    file.copy(data_files, data_dir)
    file.copy(www_files, www_dir)
    file.copy(html_files, html_dir)
    file.copy(local_files, local_dir)

  } else if (grepl("flex", type, TRUE)) {
    x <- list.files(
      system.file("flexdashboard_example", package = "RInno"),
      full.names = T)

    return(x[file.copy(x, app_dir)])

  } else {
    stop("type should be 'Shiny' or 'Flexdashboard'.")
  }

  cat("Example:", file.path(wd, app_dir))
}
