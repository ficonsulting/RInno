.onAttach <- function(libname, pkgname) {

  packageStartupMessage(
    paste0("Version: ", utils::packageDescription("RInno")[["Version"]]))
  packageStartupMessage(
    paste0("Maintainer: ", utils::packageDescription("RInno")[["Maintainer"]]))
  packageStartupMessage(
    paste0("License: ", utils::packageDescription("RInno")[["License"]]))
  packageStartupMessage(
    paste0("URL: ", utils::packageDescription("RInno")[["URL"]]))
}
