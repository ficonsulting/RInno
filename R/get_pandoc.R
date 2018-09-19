#' Downloads Pandoc
#'
#' Downloads Pandoc in \code{app_dir}. If Pandoc has already been downloaded, \code{get_Pandoc} will use that file. If the download fails it will stop.
#'
#' If \code{\link{create_app}(include_Pandoc = TRUE)}, then \code{get_Pandoc}.
#'
#' @inheritParams create_app
#' @param Pandoc_version Pandoc version to use, defaults to: \link[rmarkdown]{pandoc_available}. This ensures that the same version of Pandoc used during development is installed on users' computers.
#'
#' @return
#' \code{sprintf("pandoc-\%s-windows.msi", Pandoc_version)} in \code{app_dir}.
#'
#' @inherit setup_section seealso
#' @author Jonathan M. Hill and Hanjo Odendaal
#' @export

get_Pandoc <- function(app_dir, Pandoc_version = rmarkdown::pandoc_version()) {
  Pandoc_url <- sprintf("https://github.com/jgm/pandoc/releases/download/%s/pandoc-%s-windows.msi", Pandoc_version, Pandoc_version)

  filename <- file.path(app_dir, sprintf("pandoc-%s-windows.msi", Pandoc_version))

  if (file.exists(filename)) {
    cat("Using the copy of Pandoc already included:\n - ", filename, "\n")
  } else {
    cat(sprintf("Downloading Pandoc-%s ...\n", Pandoc_version))

    tryCatch(curl::curl_download(Pandoc_url, filename),
             error = function(e) {
               cat(glue::glue("
                              {Pandoc_url} is not a valid URL.

                              This is likely to have happened because there was a change in the URL.

                              This might have already been fixed in the latest version of RInno. Install it with remotes::install_github('ficonsulting/RInno').

                              If this doesn't help please submit an issue: {packageDescription('RInno', fields = 'BugReports')}

                              - Thanks!
                              "))
             })

    if (!file.exists(filename)) stop(glue::glue("{filename} failed to download."))
  }
}
