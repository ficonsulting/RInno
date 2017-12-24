#' Downloads R
#'
#' Downloads R in \code{app_dir}. If it has already been downloaded, \code{get_R} will use that file. If the download fails it will stop.
#'
#' If \code{\link{create_app}(include_R = TRUE)}, then \code{get_R}.
#'
#' @inheritParams create_app
#'
#' @return
#' \code{sprintf('R-\%s-win.exe', R_version)} in \code{app_dir}.
#'
#' @inherit setup_section seealso
#' @author Jonathan M. Hill
#' @export

get_R <- function(app_dir,
                  R_version = paste0(">=", R.version$major, ".", R.version$minor)) {

  R_version <- sanitize_R_version(R_version, clean = TRUE)

  latest_R_version <-
    unique(stats::na.omit(stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/", warn = F), "[1-3]\\.[0-9]+\\.[0-9]+")))

  old_R_versions <- stats::na.omit(stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/old/", warn = F), "[1-3]\\.[0-9]+\\.[0-9]+"))

  if (!R_version %in% c(latest_R_version, old_R_versions)) stop(glue::glue("That version of R ({R_version}) does not exist."), call. = F)

  if (latest_R_version == R_version) {
    base_url <- glue::glue("https://cran.r-project.org/bin/windows/base/R-{R_version}-win.exe")
  } else {
    base_url <- glue::glue("https://cran.r-project.org/bin/windows/base/old/{R_version}/R-{R_version}-win.exe")
  }

  filename <- file.path(app_dir, glue::glue("R-{R_version}-win.exe"))

  if (file.exists(filename)) {
    cat("Using the copy of R already included:\n", filename)
  } else {
    cat(glue::glue("Downloading R-{R_version} ...\n"))

    tryCatch(curl::curl_download(base_url, filename),
      error = function(e) {
        cat(glue::glue("
                              {base_url} is not a valid URL.

                              This is likely to have happened because there was a change in the URL.

                              This might have already been fixed in the latest version of RInno. Install it with devtools::install_github('ficonsulting/RInno').

                              If this doesn't help please submit an issue: {packageDescription('RInno', fields = 'BugReports')}

- Thanks!
  "))
  })

  if (!file.exists(filename)) stop(glue::glue("{filename} failed to download."), call. = F)
  }
}
