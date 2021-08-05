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

get_R <- function(app_dir = getwd(),
                  R_version = paste0(">=", R.version$major, ".", R.version$minor)) {

  if (!dir.exists(app_dir)) stop(glue::glue("{app_dir} does not exist."), call. = FALSE)

  R_version <- sanitize_R_version(R_version, clean = TRUE)

  latest_R_version <- readLines("https://cran.rstudio.com/bin/windows/base/", warn = F) %>%
    stringr::str_extract("[1-4]\\.[0-9]+\\.[0-9]+") %>% stats::na.omit() %>% unique()

  old_R_versions <- readLines("https://cran.rstudio.com/bin/windows/base/old/", warn = F) %>%
    stringr::str_extract("[1-4]\\.[0-9]+\\.[0-9]+") %>% stats::na.omit()

  if (latest_R_version == R_version) {
    base_url <- glue::glue("https://cran.r-project.org/bin/windows/base/R-{R_version}-win.exe")
  } else {
    base_url <- glue::glue("https://cran.r-project.org/bin/windows/base/old/{R_version}/R-{R_version}-win.exe")
  }

  filename <- file.path(app_dir, glue::glue("R-{R_version}-win.exe"))

  if (file.exists(filename)) {
    cat("Using the copy of R already included:\n", filename, "\n")
  } else {
    cat(glue::glue("Downloading R-{R_version} ...\n"))

    if (!R_version %in% c(latest_R_version, old_R_versions)) stop(glue::glue("That version of R ({R_version}) is not listed on CRAN."), call. = F)

    tryCatch(curl::curl_download(base_url, filename),
      error = function(e) {
        cat(glue::glue("
          {base_url} is not a valid URL.

          This is likely to have happened because there was a change in the URL.

          This might have already been fixed in the latest version of RInno. Install it with remotes::install_github('ficonsulting/RInno').

          If this doesn't help please submit an issue: {packageDescription('RInno', fields = 'BugReports')}

          - Thanks!\n"))
    })

    if (!file.exists(filename)) stop(glue::glue("{filename} failed to download."), call. = FALSE)
  }
}
