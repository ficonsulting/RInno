#' Setup Section of ISS
#'
#' This section contains global settings used by the installer and uninstaller. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setupsection}{[Setup]} for details.
#' @inheritParams create_app
#' @param iss Character vector which cumulatively becomes an Inno Setup Script (ISS).
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
#' @param inst_pw Installer password, string. Visit the Inno Setup \href{http://www.jrsoftware.org/isdl.php}{Downloads} page and place \emph{ISCrypt.dll} in your Inno Setup directory. Afterwards, if a \code{inst_pw} is supplied, then the contents of the installer will be encrypted using a 160-bit key derived from the password string. See \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_password}{[Setup]:Password} and \href{http://www.jrsoftware.org/ishelp/index.php?topic=setup_encryption}{[Setup]:Encryption} for details.
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
#'   directives_section(
#'     include_R = FALSE, R_version = '3.3.2') %>%
#'   setup_section(
#'     dir_out = 'installer', default_dir = 'pf')
#' }
#'
#' @seealso \code{\link{get_R}}, \code{\link{copy_installation}}, \code{\link{create_config}}, \code{\link{create_bat}}, \code{\link{directives_section}}, \code{\link{setup_section}}, \code{\link{languages_section}}, \code{\link{tasks_section}}, \code{\link{files_section}}, \code{\link{icons_section}}, \code{\link{run_section}}, and \code{\link{code_section}}.
#' @author Jonathan M. Hill
#' @export

setup_section <- function(iss, app_dir, dir_out,
  app_version = "{#MyAppVersion}",
  name        = "{#MyAppName}",
  publisher   = "{#MyAppPublisher}",
  default_dir = "userdocs",
  privilege   = "lowest",
  info_before = "infobefore.txt",
  info_after  = "infoafter.txt",
  license_file= "none",
  setup_icon  = "setup.ico",
  inst_pw     = "none",
  pub_url     = "{#MyAppURL}",
  sup_url     = "{#MyAppURL}",
  upd_url     = "{#MyAppURL}",
  compression = "lzma2/ultra64") {

  # Reset defaults if empty
  for (formal in names(formals(setup_section))) {
    if (length(get(formal)) == 0) assign(formal, formals(setup_section)[formal])
  }

  # If infobefore or infoafter are not the default, remove the old file
  if (info_before != formals(setup_section)$info_before) {
    suppressWarnings(file.remove(file.path(app_dir, formals(setup_section)$info_before)))
  }
  if (!file.exists(file.path(app_dir, info_before))) {
    warning(glue::glue("Make sure {info_before} is in {app_dir}/ before you call compile_iss()"), call. = FALSE)
  }
  if (info_after != formals(setup_section)$info_after) {
    suppressWarnings(file.remove(file.path(app_dir, formals(setup_section)$info_after)))
  }
  if (!file.exists(file.path(app_dir, info_after))) {
    warning(glue::glue("Make sure {info_after} is in {app_dir}/ before you call compile_iss()"), call. = FALSE)
  }
  # If setup_icon is not the default, remove the default file
  if (setup_icon != formals(setup_section)$setup_icon) {
    suppressWarnings(file.remove(file.path(app_dir, formals(setup_section)$setup_icon)))
  }
  if (!file.exists(file.path(app_dir, setup_icon))) {
    warning(glue::glue("Make sure {setup_icon} is in {app_dir}/ before you call compile_iss()"), call. = FALSE)
  }

  # Copy RInno's license into app_dir
  file.copy(system.file("LICENSE", package = "RInno"),
            file.path(app_dir, "LICENSE"))

  # If a second license file is not provided, the standard license is NULL
  if (license_file == formals(setup_section)$license_file) {
    license_file <- NULL
  } else {
    if (!file.exists(file.path(app_dir, license_file))) {
      warning(glue::glue("Make sure {license_file} is in {app_dir} before you call compile_iss()"), call. = FALSE)
    }
  }

  if (inst_pw == formals(setup_section)$inst_pw) {
    encrypt <- NULL
    inst_pw <- NULL

  } else {

    # Encrypt the installer if a pw is provided
    encrypt <- "yes"

    # Find the Inno Setup folder
    progs <- c(list.dirs("C:/Program Files", T, F),
               list.dirs("C:/Program Files (x86)", T, F))
    inno <- progs[grep("Inno Setup", progs)]

    # Check for the encryption Module
    if (!file.exists(file.path(inno, "ISCrypt.dll"))) {
      stop("RInno could not find ISCrypt.dll in your Inno Setup directory. Make sure you have followed the installation instructions found on Inno Setup's downloads page (http://www.jrsoftware.org/isdl.php) to use this feature.")
    }
  }

  # Inno Setup AppId must be a 32-bit random string that follows this pattern
  app_id <- paste0("AppId = {{", paste0(lapply(lapply(c(8, 4, 4, 4, 12), stringi::stri_rand_strings, length = 1, pattern = "[A-Z0-9]"), paste0, collapse = ""), collapse = "-"), "}")

  # glue with << and >> so that brackets can be preserved
  iss <- glue::glue('
    <<iss>>
    [Setup]
    AppName = <<name>>
    <<app_id>>
    DefaultDirName = {<<default_dir>>}\\<<name>>
    DefaultGroupName = <<name>>
    OutputDir = <<dir_out>>
    OutputBaseFilename = setup_<<name>>
    SetupIconFile = <<setup_icon>>
    AppVersion = <<app_version>>
    AppPublisher = <<publisher>>
    AppPublisherURL = <<pub_url>>
    AppSupportURL = <<sup_url>>
    AppUpdatesURL = <<upd_url>>
    PrivilegesRequired = <<privilege>>
    InfoBeforeFile = <<info_before>>
    InfoAfterFile = <<info_after>>
    Compression = <<compression>>
    SolidCompression = yes
    ArchitecturesInstallIn64BitMode = x64', .open = "<<", .close = ">>")

  if (length(license_file) > 0) {
    iss <- glue::glue("
      {iss}
      LicenseFile = {license_file}")
  }
  if (length(encrypt) > 0) {
    iss <- glue::glue("
      {iss}
      Encryption = {encrypt}")
  }
  if (length(inst_pw) > 0) {
    iss <- glue::glue("
      {iss}
      Password = {inst_pw}")
  }

  return(iss)
}
