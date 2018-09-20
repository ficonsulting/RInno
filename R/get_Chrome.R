#' Downloads Chrome
#'
#' Downloads Chrome in \code{app_dir}. If Chrome has already been downloaded, \code{get_Chrome} will use that file. If the download fails it will stop.
#'
#' If \code{\link{create_app}(include_Chrome = TRUE)}, then \code{get_Chrome}.
#'
#' @inheritParams create_app
#'
#' @return
#' chrome_installer.exe in \code{app_dir}.
#'
#' @inherit setup_section seealso
#' @author Jonathan M. Hill
#' @export

get_Chrome <- function(app_dir) {
  Chrome_url <- "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
  filename   <- file.path(app_dir, "chrome_installer.exe")

  if (file.exists(filename)) {
    cat("Using the copy of Chrome already included:\n - ", filename, "\n")
  } else {
    cat("Downloading Chrome...\n")

    tryCatch(curl::curl_download(Chrome_url, filename),
             error = function(e) {
               cat(glue::glue("
                              {Chrome_url} is not a valid URL.

                              This is likely to have happened because there was a change in the URL.

                              This might have already been fixed in the latest version of RInno. Install it with remotes::install_github('ficonsulting/RInno').

                              If this doesn't help please submit an issue: {packageDescription('RInno', fields = 'BugReports')}

- Thanks!
  "))
    })

    if (!file.exists(filename)) stop(glue::glue("{filename} failed to download."))
  }
}


