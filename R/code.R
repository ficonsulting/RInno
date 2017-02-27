#' Pascal script to check registry for R
#'
#' Modern Delphi-like Pascal adds a lot of customization possibilities to the
#' installer. For examples, please visit \href{http://www.jrsoftware.org/ishelp/topic_scriptintro.htm}{Pascal Scripting Introduction}.
#'
#' This script checks the registry for R, so that R will only be installed if necessary.
#'
#' @inheritParams setup
#'
#' @examples \dontrun{
#' readLines(system.file('deployment/code.iss', package = 'RInno'))
#' }
#'
#' @inherit setup return seealso
#'
#' @author Jonathan M. Hill
#' @export

code <- function(iss) {
  iss <- c(iss,
    readLines(system.file("deployment/code.iss", package = "RInno")))

  iss
}
