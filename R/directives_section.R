#' Inno Setup Preprocessor (ISPP) Directives
#'
#' Sets ISPP directives at the top of an ISS.
#'
#' ISPP directives automate compile-time tasks and decrease the probability
#' of typos. When referring to an ISPP directive, use
#' '\{#var_name\}'. For more information, call \code{ispp_doc()} or visit
#' \href{http://www.jrsoftware.org/ispphelp/topic_directives.htm}{ISPP Help}.
#'
#' \code{custom_vars} and \code{custom_values} utilize the #define directive.
#'
#' @param main_url String. Defaults to "".
#' @param custom_vars String vector. Defaults to "", and must be the same length as \code{custom_values}.
#' @param custom_values String vector of values for \code{custom_vars}. Defaults to "", and must be the same length as \code{custom_vars}.
#'
#' @inheritParams create_app
#' @inherit setup_section return seealso params
#'
#' @examples
#' \dontrun{
#' start_iss('myapp') %>%
#'   directives_section(
#'     include_R = FALSE, R_version = '3.3.2',
#'     custom_vars = 'helpers',
#'     custom_values = 'path\\to\\helpers') %>%
#'   files_section(
#'     app_dir = getwd(),
#'     file_list = '{#helpers}')
#' }
#'
#' @author Jonathan M. Hill
#' @export

directives_section <- function(app_name, include_R = FALSE,
  R_version = paste0(R.version$major, ".", R.version$minor),
  include_Pandoc = FALSE, Pandoc_version = rmarkdown::pandoc_version(),
  include_Chrome = FALSE, include_Rtools = FALSE, Rtools_version = "3.5",
  app_version = "0.0.0", publisher = "", main_url = "",
  custom_vars = "", custom_values = "") {

  R_version <- sanitize_R_version(R_version, clean = TRUE)
  Rtools_version <- gsub("\\.", "", Rtools_version)

  # Reset defaults if empty
  for (formal in names(formals(directives_section))) {
    if (length(get(formal)) == 0) assign(formal, formals(directives_section)[formal])
  }

  if (!custom_vars == "") {
    custom_ispp <- glue::glue('#define {custom_vars} "{custom_values}"')
  } else {
    custom_ispp <- ""
  }

  glue::glue('#define MyAppName "{app_name}"
    #define MyAppVersion "{app_version}"
    #define MyAppExeName "{paste0(app_name, ".bat")}"
    #define RVersion "{R_version}"
    #define IncludeR {tolower(include_R)}
    #define PandocVersion "{Pandoc_version}"
    #define IncludePandoc {tolower(include_Pandoc)}
    #define IncludeChrome {tolower(include_Chrome)}
    #define RtoolsVersion "{Rtools_version}"
    #define IncludeRtools {tolower(include_Rtools)}
    #define MyAppPublisher "{publisher}"
    #define MyAppURL "{main_url}"
    {custom_ispp}')
}
