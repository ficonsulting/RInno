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

  # Find the command line compiler for Inno Setup
  progs <- c(list.dirs("C:/Program Files", T, F),
             list.dirs("C:/Program Files (x86)", T, F))

  inno <- progs[grep("Inno Setup", progs)]

  if (!dir.exists(inno)) stop("RInno knocked, but Inno Setup did not answer from C:/Program Files. Install Inno Setup via install_inno(), and try again!")

  compil32 <- file.path(inno, "Compil32.exe")

  if (!file.exists(compil32)) stop(sprintf("Failed to find %s. Install Inno Setup via install_inno(), and try again!", compil32))

  iss_file <- file.path(app_dir, paste0(app_name, ".iss"))

  system(sprintf('"%s" /cc "%s"', compil32, iss_file))
}
