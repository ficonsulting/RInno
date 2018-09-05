#' Run Section of ISS
#'
#' Specifies any number of programs to execute after the program has been successfully installed, but before the installer displays the final dialog. See \href{http://www.jrsoftware.org/ishelp/topic_runsection.htm}{[Run]} for details.
#'
#' @param R_flags String of flags to customize R's installation. Defaults to "/SILENT". For other options, visit \href{https://cran.r-project.org/bin/windows/base/rw-FAQ.html#Can-I-customize-the-installation_003f}{Section 2.4} of the R FAQ. If using the '/DIR=""C:\\myapp""' flag, use double backslashes and double quotes. For more information on valid Inno Setup constants, see the \href{http://www.jrsoftware.org/ishelp/index.php?topic=consts}{Constants} section.
#'
#' @examples
#' \dontrun{
#' # You can combine custom R installation flags with Inno Setup constants
#' create_app("myapp", "app", R_flags = '/SILENT /DIR=""{userdocs}""')
#'
#' # Or directly
#' run_section(iss, R_flags = '/SILENT /DIR=""{userdocs}""')
#'
#' }
#'
#' @inherit setup_section return seealso params
#' @author Jonathan M. Hill
#' @export

run_section <- function(iss, R_flags = "/SILENT") {

  # Reset defaults if empty
  for (formal in names(formals(run_section))) {
    if (length(get(formal)) == 0) assign(formal, formals(run_section)[formal])
  }

  glue::glue('
    {iss}

    [Run]
    #if IncludeR
        Filename: "{{tmp}}\\R-{{#RVersion}}-win.exe"; Parameters: "{R_flags}"; WorkingDir: {{tmp}}; Check: RNeeded; Flags: skipifdoesntexist; StatusMsg: "Installing R if needed"
    #endif
    #if IncludePandoc
        Filename: "msiexec.exe"; Parameters: "/i ""{{tmp}}\\pandoc-{{#PandocVersion}}-windows.msi"" /q"; WorkingDir: {{tmp}}; Check: PandocNeeded; Flags: skipifdoesntexist; StatusMsg: "Installing Pandoc if needed"
    #endif
    #if IncludeChrome
        Filename: "{{tmp}}\\chrome_installer.exe"; Parameters: "/install"; WorkingDir: {{tmp}}; Check: ChromeNeeded; Flags: skipifdoesntexist; StatusMsg: "Installing Chrome if needed"
    #endif
    #if IncludeRtools
        Filename: "{{tmp}}\\Rtools{{#RtoolsVersion}}.exe"; Parameters: "/VERYSILENT"; WorkingDir: {{tmp}}; Flags: skipifdoesntexist; StatusMsg: "Installing Rtools"
    #endif
    Filename: "{{app}}\\{{#MyAppExeName}}"; Description: "', "{{cm:LaunchProgram,{{#StringChange(MyAppName, '&', '&&'", ')}}}}"; Flags: shellexec postinstall skipifsilent\n\n
  ')

}



