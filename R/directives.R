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
#' @param main_url String. Defaults to " ".
#' @param custom_vars String vector. Defaults to " ", and must be the same length as \code{custom_values}.
#' @param custom_values String vector of values for \code{custom_vars}. Defaults to " ", and must be the same length as \code{custom_vars}.
#'

#' @inheritParams create_app
#' @inherit setup return seealso params
#'
#' @examples
#' \dontrun{
#' start_iss('myapp') %>%
#'   directives(include_R = FALSE, R_version = '3.3.2',
#'     custom_vars = 'helpers', custom_values = 'path\\to\\helpers') %>%
#'   files(app_dir = getwd(),
#'     file_list = '{#helpers}')
#' }
#'
#' @author Jonathan M. Hill
#' @export

directives <- function(app_name, include_R = FALSE,
  R_version = paste0(R.version$major, ".", R.version$minor),
  include_Pandoc = FALSE, Pandoc_version = rmarkdown::pandoc_version(),
  app_version = "0.0.0", publisher = "", main_url = "",
  custom_vars = "", custom_values = "") {

  # Reset defaults if empty
  for (formal in names(formals(directives))) {
    if (length(get(formal)) == 0) assign(formal, formals(directives)[formal])
  }

  if (!custom_vars == "") {
    custom_ispp <- sprintf('#define %s "%s"', custom_vars, custom_values)
  } else {
    custom_ispp <- ""
  }

  opts <- c(
    # Required
    sprintf('#define MyAppName "%s"', app_name),
    sprintf('#define MyAppVersion "%s"', app_version),
    sprintf('#define MyAppExeName "%s"', paste0(app_name, '.bat')),
    sprintf('#define RVersion "%s"', R_version),
    sprintf('#define IncludeR %s', tolower(include_R)),
    sprintf('#define PandocVersion "%s"', Pandoc_version),
    sprintf('#define IncludePandoc %s', tolower(include_Pandoc)),

    # Optional
    sprintf('#define MyAppPublisher "%s"', publisher),
    sprintf('#define MyAppURL "%s"', main_url),
    custom_ispp)

  opts
}
