#' Downloads Rtools
#'
#' Downloads Rtools in \code{app_dir}. If it has already been downloaded, \code{get_Rtools} will use that file. If the download fails it will stop.
#'
#' If \code{\link{create_app}(include_Rtools = TRUE)}, then \code{get_Rtools}.
#'
#' @inheritParams create_app
#'
#' @return
#' \code{sprintf('Rtools\%s.exe', gsub("\\.", "", Rtools_version))} in \code{app_dir}.
#'
#' @inherit setup_section seealso
#' @author Jonathan M. Hill
#' @export

get_Rtools <- function(app_dir, Rtools_version, R_version) {

  if (!dir.exists(app_dir)) stop(glue::glue("{app_dir} does not exist."), call. = FALSE)

  R_version <- sanitize_R_version(R_version, clean = TRUE)

  # Rtools info ---------------------------------------------------
  # ---------------------------------------------------------------
  Rtools_url <- "http://cran.r-project.org/bin/windows/Rtools/"
  version_info <- list(
    "2.11" = list(
      version_min = "2.10.0",
      version_max = "2.11.1"
    ),
    "2.12" = list(
      version_min = "2.12.0",
      version_max = "2.12.2"
    ),
    "2.13" = list(
      version_min = "2.13.0",
      version_max = "2.13.2"
    ),
    "2.14" = list(
      version_min = "2.13.0",
      version_max = "2.14.2"
    ),
    "2.15" = list(
      version_min = "2.14.2",
      version_max = "2.15.1"
    ),
    "2.16" = list(
      version_min = "2.15.2",
      version_max = "3.0.0"
    ),
    "3.0" = list(
      version_min = "2.15.2",
      version_max = "3.0.99"
    ),
    "3.1" = list(
      version_min = "3.0.0",
      version_max = "3.1.99"
    ),
    "3.2" = list(
      version_min = "3.1.0",
      version_max = "3.2.99"
    ),
    "3.3" = list(
      version_min = "3.2.0",
      version_max = "3.3.99"
    ),
    "3.4" = list(
      version_min = "3.3.0",
      version_max = "3.4.99"
    ),
    "3.5" = list(
      version_min = "3.3.0",
      version_max = "99.99.99"
    )
  )

  Rtools_versions <- gsub("^(.{1})(.*)$", "\\1\\.\\2", gsub("Rtools", "",
    unique(stats::na.omit(
      stringr::str_extract(readLines(Rtools_url, warn = F), "Rtools[0-9]+")
    ))
  ))

  if (!Rtools_version %in% Rtools_versions) stop(glue::glue("That version of Rtools ({Rtools_version}) does not exist."), call. = F)

  is_not_compatible <- function() {
    info <- version_info[[Rtools_version]]
    !(R_version >= info$version_min && R_version <= info$version_max)
  }

  if (is_not_compatible()) stop(glue::glue("Rtools {Rtools_version} is not compatible with R {R_version}. Please check {Rtools_url} for more information."))

  Rtools_file <- paste0("Rtools", gsub("\\.", "", Rtools_version), ".exe")

  filename <- file.path(app_dir, Rtools_file)
  download_url <- paste0(Rtools_url, Rtools_file)

  if (file.exists(filename)) {
    cat("Using the copy of Rtools already included:\n", filename, "\n")
  } else {
    cat(glue::glue("Downloading Rtools {Rtools_version} ...\n"))

    tryCatch(curl::curl_download(download_url, filename),
             error = function(e) {
               cat(glue::glue("
                              {download_url} is not a valid URL.

                              This is likely to have happened because there was a change in the URL.

                              This might have already been fixed in the latest version of RInno. Install it with remotes::install_github('ficonsulting/RInno').

                              If this doesn't help please submit an issue: {packageDescription('RInno', fields = 'BugReports')}

                              - Thanks!
                              "))
             })

    if (!file.exists(filename)) stop(glue::glue("{filename} failed to download."), call. = FALSE)
  }
}


