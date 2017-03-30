#' @title Downloads and installs Inno Setup
#'
#' @description Downloads and installs Inno Setup's \href{http://www.jrsoftware.org/isdl.php#stable}{stable release}
#'
#' @details
#' Inno Setup is a free installer for Windows programs. First introduced in 1997, it currently rivals many commercial installers in feature set and stability.
#'
#' See \href{http://www.jrsoftware.org/isinfo.php#features}{Features} for more information.
#'
#' @return TRUE/FALSE - was the installation successful or not.
#'
#' @author Tal Galili and Jonathan M. Hill
#'
#' @param quick_start_pack The Inno Setup QuickStart Pack includes Inno Setup and Inno Script Studio script editor. See \href{http://www.jrsoftware.org/is3rdparty.php}{Third-Party Files} page for more information.
#'
#' @param ... extra parameters to pass to \code{\link[installr]{install.URL}}
#'
#' @examples
#'
#' \dontrun{
#' install_inno()
#' install_inno(quick_start_pack = T)
#' }
#'
#' @export

install_inno <- function(
  quick_start_pack = FALSE,
  ...) {

  page_with_download_url = 'http://www.jrsoftware.org/download.php/'
  exe_filename = 'is.exe'

  if (quick_start_pack) {
    exe_filename = 'ispack.exe'
  }

  URL <- paste0(page_with_download_url, exe_filename)

  installr::install.URL(URL, ...)
}
