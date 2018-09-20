#' Files Section of ISS
#'
#' Files to be installed on user's computer. Everything in \code{app_dir} plus
#' \code{file_list}. For more information, visit \href{http://www.jrsoftware.org/ishelp/index.php?topic=filessection}{[Files] section}.
#'
#' @inheritParams create_app
#' @param file_list Character vector. Extra files to be installed with the app.
#'
#' @inherit setup_section return params
#' @author Jonathan M. Hill
#' @export

files_section <- function(iss, app_name, app_dir, user_browser, file_list = character()) {

  all_files <- list.files(app_dir, recursive = T)

  # If a file list is not provided than list only files in app_dir
  if (length(file_list) == 0) {
    all_files <- all_files[!grepl("iss$|info.*txt$|exe$", all_files)]
  } else {
    all_files <- c(file_list, all_files[!grepl("iss$|info.*txt$|exe$", all_files)])
  }
  if (user_browser == "electron") {
    all_files <- c(
      all_files,
      file.path("nativefier-app", list.files(file.path(app_dir, "nativefier-app"), pattern = ".exe", recursive = TRUE))
    )
  }

  # Get file paths with dirname(), if no path (file in app directory/not contained in a subdirectory) dirname() returns "."
  file_dirs <- dirname(all_files)
  # Replace "." exact match with "" empty character
  file_dirs[which(file_dirs == ".")] <- ""
  # Modify path separators
  file_dirs <- gsub("/", "\\\\", file_dirs)
  blank_dirs    <- file_dirs == ""
  nonblank_dirs <- !blank_dirs

  # Files without a directory
  blank_dir_files <- glue::glue('
    Source: "{all_files[blank_dirs]}"; DestDir: "{{app}}"; Flags: ignoreversion;')

  # Files with a directory
  dir_files <- glue::glue('
    Source: "{all_files[nonblank_dirs]}"; DestDir: "{{app}}\\{file_dirs[nonblank_dirs]}"; Flags: ignoreversion;')

glue::glue('
{iss}

[Files]
Source: "LICENSE"; Flags: dontcopy noencryption
Source: "{{#MyAppExeName}}"; DestDir: "{{app}}"; Flags: ignoreversion
#if IncludeR
    Source: "R-{{#RVersion}}-win.exe"; DestDir: "{{tmp}}"; Check: RNeeded
#endif
#if IncludePandoc
    Source: "pandoc-{{#PandocVersion}}-windows.msi"; DestDir: "{{tmp}}"; Check: PandocNeeded
#endif
#if IncludeChrome
    Source: "chrome_installer.exe"; DestDir: "{{tmp}}"; Check: ChromeNeeded
#endif
#if IncludeRtools
    Source: "Rtools{{#RtoolsVersion}}.exe"; DestDir: "{{tmp}}";
#endif
{glue::glue_collapse(blank_dir_files, "\n")}
{glue::glue_collapse(dir_files, "\n")}
')
}
