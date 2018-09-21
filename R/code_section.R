#' Pascal script to check registry for R
#'
#' Modern Delphi-like Pascal adds a lot of customization possibilities to the
#' installer. For examples, please visit \href{http://www.jrsoftware.org/ishelp/topic_scriptintro.htm}{Pascal Scripting Introduction}.
#'
#' This script checks the registry for R, so that R will only be installed if necessary.
#'
#' @inheritParams setup_section
#' @inheritParams create_app
#'
#' @examples \dontrun{
#' readLines(system.file('installation/code.iss', package = 'RInno'))
#' }
#'
#' @inherit setup_section return seealso
#'
#' @author Jonathan M. Hill
#' @export
code_section <- function(iss, R_version = paste0(">=", R.version$major, ".", R.version$minor)) {

  # Reset defaults if empty
  if (length(R_version) == 0) {
    R_version = paste0(">=", R.version$major, ".", R.version$minor)
  }
  # Sanitize R_version
  R_version <- sanitize_R_version(R_version)

  # Get available versions of R
  R_versions <-
    c(
      unique(stats::na.omit(stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/", warn = F), "[1-3]\\.[0-9]+\\.[0-9]+"))),
      stats::na.omit(stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/old/", warn = F), "[1-3]\\.[0-9]+\\.[0-9]+")))

  # Determine which versions are acceptable
  inequality <- substr(R_version, 1, attr(regexpr("[<>=]+", R_version), "match.length"))
  R_version <- gsub("[<>=]", "", R_version)
  version_specs <- paste0("numeric_version('", R_versions, "')",
                          inequality,
                          "numeric_version('", R_version, "')")

  if (!R_version %in% R_versions && interactive()) stop(glue::glue("R version - {R_version} - was not found on CRAN. Please use `R_version` to specify one that is or let us know if you think you received this message in error: \n\nhttps://github.com/ficonsulting/RInno/issues"), call. = FALSE)

  results <- unlist(lapply(version_specs, function(x) eval(parse(text = x))))
  acceptable_R_versions <-
    paste0(glue::glue("RVersions.Add('{R_versions[results]}');"), collapse = "\n  ")

  # Read in the code section from the package
  code_file <- paste0(
    readLines(system.file("installation/code.iss", package = "RInno")),
    collapse = "\n")

  # Find InitializeWizard and add RVersions

  glue::glue('{iss}
  {code_file}
  // Initialize the values of supported versions
  RVersions := TStringList.Create; // Make a new TStringList object reference
  // Add strings to the StringList object
  {acceptable_R_versions}

end;

// Procedure called by InnoSetup when it is closing
procedure DeinitializeSetup();
begin
  RVersions.Free;
end;
  ')
}
