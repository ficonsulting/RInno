#' File Section of ISS
#'
#' Files to be installed on user's computer. Everything in \code{app_dir} plus
#' \code{file_list}. For more information, visit \href{http://www.jrsoftware.org/ishelp/topic_filessection.htm}{[Files] section} or call \code{inno_doc()}.
#'
#' @inheritParams create_app
#' @param file_list Character vector. Extra files to be installed with the app.
#'
#' @inherit setup return params
#' @author Jonathan M. Hill
#' @export

files <- function(iss, app_dir, file_list = character()) {

  # If a file list is not provided than list only files in app_dir
  if (length(file_list) == 0) {
    all_files <- list.files(app_dir, recursive = T)[
      !grepl("iss$|readme.txt", list.files(app_dir, recursive = T))]
  } else {
    all_files <- c(file_list, list.files(app_dir, recursive = T)[
      !grepl("iss$|readme.txt", list.files(app_dir, recursive = T))])
  }

  file_dirs     <- gsub("\\.", "", dirname(all_files))
  blank_dirs    <- file_dirs == ""
  nonblank_dirs <- !blank_dirs

  iss <- c(iss, gsub("/", "\\\\", c(
  '\n[Files]',
  'Source: "{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion',

  '#if IncludeR',
  '    Source: "R-{#RVersion}-win.exe"; DestDir: "{tmp}"; Check: RNeeded',
  '#endif',

  sprintf('Source: "%s"; DestDir: "{app}"; Flags: ignoreversion;',
          all_files[blank_dirs]),

  sprintf('Source: "%s"; DestDir: "{app}\\%s"; Flags: ignoreversion;',
          all_files[nonblank_dirs], file_dirs[nonblank_dirs]))))

  iss
}
