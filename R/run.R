#' Run Section of ISS
#'
#' Specifies any number of programs to execute after the program has been successfully installed, but before the installer displays the final dialog. See \href{http://www.jrsoftware.org/ishelp/topic_runsection.htm}{[Run] section} for details.
#'
#' @inherit setup return seealso params
#' @author Jonathan M. Hill
#' @export

run <- function(iss) {
 iss <- c(iss, '\n[Run]',
    paste0('#if IncludeR\n\tFilename: "{tmp}\\R-{#RVersion}-win.exe"; Parameters: "/SILENT"; WorkingDir: {tmp}; Flags: skipifdoesntexist; StatusMsg: "Installing R if needed"\n#endif\nFilename: "{app}\\{#MyAppExeName}"; Description: "', "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&'", ')}}"; Flags: shellexec postinstall skipifsilent\n\n'))

 iss
}
