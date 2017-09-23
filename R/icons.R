#' Icons Section of ISS
#'
#' Shortcuts Inno Setup creates in the Start Menu and/or other locations,
#' such as the desktop. For more information, see \href{http://www.jrsoftware.org/ishelp/topic_iconssection.htm}{[Icons] section}, or call \code{inno_doc()}.
#'
#' @param app_desc Description of Shiny app, appears on mouse-over of icons.
#' @param app_icon Filename of icon in \code{app_dir}, used for desktop and program menu shortcuts.
#' @param prog_menu_icon Logical. If TRUE, create a program menu shortcut.
#' @param desktop_icon Logical. If TRUE, create a desktop shortcut.
#'
#' @examples \dontrun{
#' start_iss('myapp') %>%
#'   icons(app_desc = 'This Shiny app is awesome!')
#' }
#'
#' @inherit setup return seealso params
#' @author Jonathan M. Hill
#' @export

icons <- function(iss, app_dir,
  app_desc = "", app_icon = "default.ico",
  prog_menu_icon = TRUE, desktop_icon = TRUE) {

  # Reset defaults if empty
  for (formal in names(formals(icons))) {
    if (length(get(formal)) == 0) assign(formal, formals(icons)[formal])
  }

  # If a custom icon is provided, delete default.ico
  if (app_icon != formals(icons)$app_icon) {
    suppressWarnings(file.remove(file.path(app_dir, formals(icons)$app_icon)))
  }
  # If app icon does not exist, warn developer
  if (!file.exists(file.path(app_dir, app_icon))) {
    warning(sprintf("Make sure %s is in %s/ before you call compile_iss()",
                    app_icon, app_dir), call. = FALSE)
  } else {
    www_dir <- file.path(app_dir, "www")
    if (!dir.exists(www_dir)) dir.create(www_dir)
    file.copy(file.path(app_dir, app_icon), www_dir)
  }

  if (app_desc == "") {
    icon_string <- sprintf('IconFilename: "{app}\\%s"', app_icon)

  } else {
    icon_string <-
      sprintf('Comment: "%s"; IconFilename: "{app}\\%s"', app_desc, app_icon)
  }

  iss <- c(iss, "\n[Icons]",
    paste('Name: "{group}\\{#MyAppName}"; Filename: "{app}\\{#MyAppExeName}";',
          icon_string),
    'Name: "{group}\\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"')

  if (as.logical(prog_menu_icon)) {
    iss <- c(iss, paste('Name: "{commonprograms}\\{#MyAppName}"; Filename: "{app}\\{#MyAppExeName}";', icon_string))
  }

  if (as.logical(desktop_icon)) {
    iss <- c(iss,
              paste('Name: "{commondesktop}\\{#MyAppName}"; Filename: "{app}\\{#MyAppExeName}"; Tasks: desktopicon;', icon_string)
    )
  }

  iss
}
