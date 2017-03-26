#' Setup Section of ISS
#'
#' This section contains global settings used by the installer and uninstaller. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setupsection}{[Setup]} for details.
#'
#' @inheritParams create_app
#' @param iss Character vector which cummulatively becomes an Inno Setup Script (ISS).
#'
#' @param app_version Version number of the app being installed, defaults to \code{'0.0.0'}. It is displayed in the Version field of the app's \emph{Add/Remove Programs} entry. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_appversion}{[Setup]:AppVersion} for details.
#'
#' @param name Defaults to ISPP directive, \code{'{#MyAppName}'} set by \code{directives(app_name)}.
#'
#' @param publisher String displayed on the "Support" dialogue of the \emph{Add/Remove Programs} Control Panel applet, defaults to " ". See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_apppublisher}{[Setup]:AppPublisher} for details.
#'
#' @param default_dir The default directory name used by the \emph{Select Destination Page} of the installer. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_defaultdirname}{[Setup]:DefaultDirName} and \href{http://www.jrsoftware.org/ishelp/index.php?topic=consts}{Constants} for details.
#'
#' @param privilege Valid options: \code{'poweruser', 'admin', 'lowest'}. Defaults to \code{'lowest'}. This directive affects whether elevated rights are requested when an installation is started. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_privilegesrequired}{[Setup]:PrivilegesRequired} for details.
#'
#' @param info_before File, in .txt or .rtf format, which is displayed on the first page of the installer. It must be located in \code{app_dir}. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_infobeforefile}{[Setup]:InfoBeforeFile} for details.
#'
#' @param info_after File, in .txt or .rtf format, which is displayed on the last page of the installer. It must be located in \code{app_dir}. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_infoafterfile}{[Setup]:InfoAfterFile} for details.
#'
#' @param setup_icon File name of the icon used for installer/uninstaller. The file must be located in \code{app_dir}. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_setupiconfile}{[Setup]:SetupIconFile} for details.
#'
#' @param license_file File, in .txt or .rtf format, which is displayed before the \emph{Select Destination Page} of the wizard. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_licensefile}{[Setup]:LicenseFile} for details.
#'
#' @param inst_pw Installer password, string. If a password is supplied then the contents of the installer will be encrypted using a 160-bit key derived from the password string. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_password}{[Setup]:Password} and \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_encryption}{[Setup]:Encryption} for details.
#'
#' @param pub_url String. Defaults to \code{'{#MyAppURL}'}, which is the ISPP directive for \code{main_url}. Therefore, \code{main_url} will be used, unless otherwise specified. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_apppublisherurl}{[Setup]:AppPublisherURL} for details.
#'
#' @param sup_url String. Defaults to \code{'{#MyAppURL}'}, which is the ISPP directive for \code{main_url}. Therefore, \code{main_url} will be used, unless otherwise specified. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_appsupporturl}{[Setup]:AppSupportURL} for details.
#'
#' @param upd_url String. Defaults to \code{'{#MyAppURL}'}, which is the ISPP directive for \code{main_url}. Therefore, \code{main_url} will be used, unless otherwise specified. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_appupdatesurl}{[Setup]:AppUpdatesURL} for details.
#'
#' @param compression Defaults to \code{'lzma2/ultra64'}, which has the best compression ratio available. Other valid options include: \code{'zip'}, \code{'bzip'}, \code{'lzma'}, and \code{'none'}.  See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_compression}{[Setup]:Compression} for details.
#'
#' @return Chainable character vector, which can be used as the \code{text} argument of \code{\link{writeLines}} to generate an ISS.
#'
#' @examples \dontrun{
#' start_iss('myapp') %>%
#'   directives(include_R = FALSE, R_version = '3.3.2') %>%
#'   setup(dir_out = 'installer', default_dir = 'pf')
#' }
#'
#' @seealso \code{\link{get_R}}, \code{\link{copy_installation}}, \code{\link{create_config}}, \code{\link{create_bat}}, \code{\link{create_pkgs}}, \code{\link{directives}}, \code{\link{setup}}, \code{\link{languages}}, \code{\link{tasks}}, \code{\link{files}}, \code{\link{icons}}, \code{\link{run}}, and \code{\link{code}}.
#' @author Jonathan M. Hill
#' @export

setup <- function(iss, dir_out,
  app_version = "{#MyAppVersion}",
  name        = "{#MyAppName}",
  publisher   = "{#MyAppPublisher}",
  default_dir = "userdocs",
  privilege   = "lowest",
  info_before = "infobefore.txt",
  info_after  = "none",
  license_file= "none",
  setup_icon  = "setup.ico",
  inst_pw     = "none",
  pub_url     = "{#MyAppURL}",
  sup_url     = "{#MyAppURL}",
  upd_url     = "{#MyAppURL}",
  compression = "lzma2/ultra64") {

  # Reset defaults if empty
  for (formal in names(formals(setup))) {
    if (length(get(formal)) == 0) assign(formal, formals(setup)[formal])
  }

  # Encrypt the installer if a pw is provided
  if (inst_pw == "none") {
    encrypt <- NULL; inst_pw <- NULL
  } else {
    encrypt <- "yes"
  }
  if (license_file == "none") license_file <- NULL
  if (info_after == "none") info_after <- NULL

  # Inno Setup AppId must be a 32-bit random string that follows this pattern
  iss <- c(iss, "\n[Setup]",
    paste0("AppId = {{", paste0(lapply(lapply(c(8, 4, 4, 4, 12),
      stringi::stri_rand_strings, length = 1, pattern = "[A-Z0-9]"),
      paste0, collapse = ""), collapse = "-"), "}"),

  # Required options
  sprintf("AppName = %s", name),
  sprintf("DefaultDirName = {%s}\\%s", default_dir, name),
  "DefaultGroupName = {#MyAppName}",
  sprintf("OutputDir = %s", dir_out),
  sprintf("OutputBaseFilename = setup_%s", name),
  sprintf("SetupIconFile = %s", setup_icon),

  # Optional options
  sprintf("AppVersion = %s", app_version),
  sprintf("AppPublisher = %s", publisher),
  sprintf("AppPublisherURL = %s", pub_url),
  sprintf("AppSupportURL = %s", sup_url),
  sprintf("AppUpdatesURL = %s", upd_url),
  sprintf("PrivilegesRequired = %s", privilege),
  sprintf("InfoBeforeFile = %s", info_before),
  sprintf("InfoAfterFile = %s", info_after),
  sprintf("Compression = %s", compression),
  sprintf("Password = %s", inst_pw),
  sprintf("Encryption = %s", encrypt),
  sprintf("LicenseFile = %s", license_file),

  # Hardcoded option
  "SolidCompression = yes")

  iss
}
