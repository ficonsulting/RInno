#' @title Downloads and installs nodejs
#'
#' @description Suports Nodejs's "current" and "lts" versions - \href{https://nodejs.org/en/download/}{LTS} - \href{https://nodejs.org/en/download/current}{Current}
#'
#' @details
#' As an asynchronous event driven JavaScript runtime, Node is designed to build scalable network applications.
#'
#' See \href{https://nodejs.org/en/about/}{About} for more information.
#'
#' @return TRUE/FALSE - was the installation successful or not.
#'
#' @author Tal Galili, A. Jonathan R. Godfrey, and Jonathan M. Hill
#'
#' @param page_with_download_url nodejs download url.
#'
#' @param version character. "current" or "lts". Defaults to "lts"
#'
#' @param ... extra parameters to pass to \code{\link[installr]{install.URL}}
#'
#' @examples
#'
#' \dontrun{
#' install_nodejs()
#' install_nodejs(version = "current")
#' }
#'
#' @export


install_nodejs = function (page_with_download_url = "https://nodejs.org/en/download/",
                           version = "LTS",
                           ...)
{

  version <- tolower(version)
  stopifnot(version %in% c("lts", "current"))

  if(version == "current"){
    page_with_download_url <- paste0(page_with_download_url, "current/")
  }
  page <- readLines(page_with_download_url, warn = FALSE)
  pat <- paste0("Latest ", version, " Version")
  target_line <- grep(pat, page, value = TRUE, ignore.case = TRUE)

  VersionNo <- regmatches(target_line, regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", target_line))[1]

  if(.Machine$sizeof.pointer == 8){
    bitNo <- "-x64"
  }else{
    bitNo <- "-x86"
  }

  installr::install.URL(paste0("https://nodejs.org/dist/v", VersionNo, "/node-v", VersionNo, bitNo, ".msi"), ...)
}
