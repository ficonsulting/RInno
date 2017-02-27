#' Inno Setup Documentation
#'
#' @return Local Inno Setup Documentation.
#'
#' @author Jonathan M. Hill
#' @export
inno_doc <- function() {
  progs <- c(list.dirs("C:/Program Files", T, F),
             list.dirs("C:/Program Files (x86)", T, F))

  inno <- progs[grep("Inno Setup", progs)]

  shell.exec(file.path(inno, "ISetup.chm"))
}

#' Inno Setup Preprossor Help
#'
#' @return Local Inno Setup Preprocessor Documentation.
#'
#' @author Jonathan M. Hill
#' @export
ispp_doc <- function() {
  progs <- c(list.dirs("C:/Program Files", T, F),
             list.dirs("C:/Program Files (x86)", T, F))

  inno <- progs[grep("Inno Setup", progs)]

  shell.exec(file.path(inno, "ISPP.chm"))
}
