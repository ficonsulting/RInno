#' Search for flexdashboard
#'
#' This function locates a flexdashboard within a file list.
#'
#' @param file_list Character vector. List of files within \code{app_dir}.
#'
#' @author Hanjo Odendaal.
#' @export

flexdashboard_check <- function(file_list) {

  for (file in file_list) {
    # Identify and read in yaml
    yaml_index <- grep("---", readLines(file), fixed = T)
    yaml_content <- readLines(file, (yaml_index[2] - 1))[-1]

    # Check for flexdashboard, and return it
    if (any(grepl("flexdashboard", yaml_content))) {
      return(basename(file))

    # If no flexdashboard is found, check the next file
    } else {
      next
    }
  }

}


