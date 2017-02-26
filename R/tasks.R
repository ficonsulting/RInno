#' Tasks Section of ISS
#'
#' Defines all of the user-customizable tasks during installation. These tasks appear as check boxes and radio buttons on the \emph{Select Additional Tasks} installer page. See \href{http://www.jrsoftware.org/ishelp/topic_taskssection.htm}{[Tasks] section} for details.
#'
#' @inheritParams icons
#'
#' @inherit setup return seealso params
#' @author Jonathan M. Hill
#' @export
tasks <- function(iss, desktop_icon = TRUE) {

  for (formal in names(formals(tasks))) {
    if (length(get(formal)) == 0) assign(formal, formals(tasks)[formal])
  }

  if (as.logical(desktop_icon)) {
  iss <- c(iss, '\n[Tasks]',
    'Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"')
  }

  iss
}
