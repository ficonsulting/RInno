#' Tasks Section of ISS
#'
#' Defines all of the user-customizable tasks during installation. These tasks appear as check boxes and radio buttons on the \emph{Select Additional Tasks} installer page. See \href{http://www.jrsoftware.org/ishelp/topic_taskssection.htm}{[Tasks] section} for details.
#'
#' @inheritParams icons_section
#'
#' @inherit setup_section return seealso params
#' @author Jonathan M. Hill
#' @export
tasks_section <- function(iss, desktop_icon = TRUE) {

  for (formal in names(formals(tasks_section))) {
    if (length(get(formal)) == 0) assign(formal, formals(tasks_section)[formal])
  }

  if (as.logical(desktop_icon)) {
    iss <- glue::glue('
                    {iss}

                    [Tasks]
                    Name: "desktopicon"; Description: "{{cm:CreateDesktopIcon}}"
                    ')
  }

  iss
}
