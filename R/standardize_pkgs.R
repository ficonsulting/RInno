#' Standardize package dependencies
#'
#' Standardizes (named or not) character vectors of package dependencies. This creates a standard format for package dependency information stored in config.cfg
#'
#' @param pkgs Processes \code{pkgs}, \code{remotes} and \code{locals}, arguments of \code{\link{create_config}} and \code{\link{create_app}}.
#'
#' @author William Bradley

standardize_pkgs <- function(pkgs) {

  if (pkgs[1] == "none") return("none")

  pkg_list <- as.list(pkgs)
  no_name <- names(pkg_list) == ""

  # If versions are not provided, use installed versions
  if (length(no_name) == 0) {

    tryCatch(pkg_list <- lapply(pkg_list, utils::packageVersion),
      error = function(e) {
        stop(e$message, "\n\nPlease provide versions of `pkgs` and `locals` if they are not installed in the development environment. \n\nWe would like to keep those consistent for the future!", call. = FALSE)
    })

    names(pkg_list) <- pkgs

  # Otherwise, use versions provided and installed versions for no_name pkgs
  } else if (sum(no_name) > 0) {

    tryCatch(pkg_list[no_name] <- lapply(pkg_list[no_name], utils::packageVersion),
      error = function(e) {
        stop(e$message, "\n\nPlease provide versions of `pkgs` and `locals` if they are not installed in the development environment. \n\nWe would like to keep those consistent for the future!", call. = FALSE)
    })

    names(pkg_list)[no_name] <- pkgs[no_name]
  }

  # convert to character for JSON
  pkgs <- lapply(pkg_list, as.character)

  return(pkgs)
}
