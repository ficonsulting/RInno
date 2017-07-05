#' @title Downloads and installs pandoc
#' @description Downloads and installs the latest version of pandoc for Windows.
#' @details
#' pandoc is a free open source software for converting documents from many filetypes to many filetypes.  For details, see \url{http://johnmacfarlane.net/pandoc/}.
#'
#' Credit: the code in this function is based on GERGELY DAROCZIs coding in his answer on the Q&A forum StackOverflow, and also G. Grothendieck for the non-XML addition to the function.
#' I thank them both!
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @author GERGELY DAROCZI, G. Grothendieck, Tal Galili
#' @param URL a link to the list of download links of pandoc
#' @param use_regex (default TRUE) - deprecated (kept for legacy purposes).
#' @param to_restart boolean. Should the computer be restarted
#'  after pandoc is installed? (if missing then the user is prompted
#' 	for a decision)
#' @param ... extra parameters to pass to \link{install.URL}
#' @source \url{http://stackoverflow.com/questions/15071957/is-it-possible-to-install-pandoc-on-windows-using-an-r-command}
#' @examples
#' \dontrun{
#' install.pandoc()
#' }

install_pandoc <- function (URL = "https://github.com/jgm/pandoc/releases",
          to_restart, ...)
{
  page_with_download_url <- URL

  page <- readLines(page_with_download_url, warn = FALSE)
  pat <- "jgm/pandoc/releases/download/[0-9.]+/pandoc-[0-9.-]+-windows\\.msi"
  target_line <- grep(pat, page, value = TRUE)
  m <- regexpr(pat, target_line)
  URL <- regmatches(target_line, m)
  URL <- head(URL, 1)
  URL <- paste("https://github.com/", URL, sep = "")
  installed <- install_URL(URL, ...)
  if (!installed)
    return(invisible(FALSE))
  if (missing(to_restart)) {
    if (is.windows()) {
      you_should_restart <- "You should restart your computer\n in order for pandoc to work properly"
      winDialog(type = "ok", message = you_should_restart)
      choices <- c("Yes", "No")
      question <- "Do you want to restart your computer now?"
      the_answer <- menu(choices, graphics = "TRUE", title = question)
      to_restart <- the_answer == 1L
    }
    else {
      to_restart <- FALSE
    }
  }
  if (to_restart)
    os.restart()
}
