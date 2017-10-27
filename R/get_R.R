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
#' @inherit setup seealso
#' @author Jonathan M. Hill
#' @export

get_R <- function(app_dir, R_version) {
  latest_R_version <-
    unique(stats::na.omit(stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/", warn = F), "[1-3]\\.[0-9]+\\.[0-9]+")))

  old_R_versions <- stats::na.omit(stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/old/", warn = F), "[1-3]\\.[0-9]+\\.[0-9]+"))

  if (!R_version %in% c(latest_R_version, old_R_versions)) stop(sprintf("That version of R (v%s) does not exist.", R_version))

  if (latest_R_version == R_version) {
    base_url <- sprintf("https://cran.r-project.org/bin/windows/base/R-%s-win.exe", R_version)
  } else {
    base_url <- sprintf("https://cran.r-project.org/bin/windows/base/old/%s/R-%s-win.exe", R_version, R_version)
  }

  filename <- file.path(app_dir, sprintf("R-%s-win.exe", R_version))

  if (file.exists(filename)) {
    cat("Using the copy of R already included:\n", filename)
  } else {
    cat(sprintf("Downloading R-%s ...\n", R_version))

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

  if (!file.exists(filename)) stop(sprintf("%s failed to download.", filename))
  }
}
