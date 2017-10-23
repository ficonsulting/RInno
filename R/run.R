#' Run Section of ISS
#'
#' Specifies any number of programs to execute after the program has been successfully installed, but before the installer displays the final dialog. See \href{http://www.jrsoftware.org/ishelp/topic_runsection.htm}{[Run]} for details.
#'
#' @param R_flags String of flags to customize R's installation. Defaults to "/SILENT". For other options, visit \href{https://cran.r-project.org/bin/windows/base/rw-FAQ.html#Can-I-customize-the-installation_003f}{Section 2.4} of the R FAQ. If useing the "/DIR='C:\\myapp'" flag, remember to escape the backslash.
#'
#' @inherit setup return seealso params
#' @author Jonathan M. Hill
#' @export

run <- function(iss, R_flags = "/SILENT") {

  # Reset defaults if empty
  for (formal in names(formals(run))) {
    if (length(get(formal)) == 0) assign(formal, formals(run)[formal])
  }

  glue::glue('
    {iss}

    [Run]
    #if IncludeR
      Filename: "{{tmp}}\\R-{{#RVersion}}-win.exe"; Parameters: "{R_flags}"; WorkingDir: {{tmp}}; Flags: skipifdoesntexist; StatusMsg: "Installing R if needed"
    #endif

    #if IncludePandoc
      Filename: "msiexec.exe"; Parameters: "/i ""{{tmp}}\\pandoc-{{#PandocVersion}}-windows.msi"" /q"; WorkingDir: {{tmp}}; Flags: skipifdoesntexist; StatusMsg: "Installing Pandoc if needed"
    #endif

    Filename: "{{app}}\\{{#MyAppExeName}}"; Description: "', "{{cm:LaunchProgram,{{#StringChange(MyAppName, '&', '&&'", ')}}}}"; Flags: shellexec postinstall skipifsilent\n\n
  ')

}



