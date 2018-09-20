#' Compile ISS
#'
#' After running \code{\link{create_app}} and editing the content of the
#' installer and app, call \code{compile_iss}.
#'
#' @return Installer in \code{dir_out}.
#'
#' @author Jonathan M. Hill
#' @export
compile_iss <- function() {

  app_name <- getOption("RInno.app_name")
  app_dir   <- getOption("RInno.app_dir")
  iss_file <- file.path(app_dir, paste0(app_name, ".iss"))

  # Find the command line compiler for Inno Setup
  inno <- find_inno()

  if (length(inno) == 0) {
    ans <- utils::menu(title = "Inno Setup was not found. Would you like to install it now?", choices = c("Yes", "No"))
    if (ans == 1) {
      install_inno()
      inno <- find_inno()
    } else {
      stop(glue::glue("Please install Inno Setup before compiling {iss_file}."), call. = FALSE)
    }
  }

  compil32 <- file.path(inno, "Compil32.exe")

  if (!file.exists(compil32)) stop(glue::glue("Failed to find {compil32}. Install Inno Setup via install_inno(), and try again!"), call. = FALSE)

  # compile
  system(glue::glue('"{compil32}" /cc "{iss_file}"'))
}


find_inno <- function(){
  progs <- c(list.dirs("C:/Program Files", TRUE, FALSE),
             list.dirs("C:/Program Files (x86)", TRUE, FALSE))

  inno <- progs[grep("Inno Setup", progs)]

  return(inno)
}
