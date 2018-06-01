#' Add package to named vector
#'
#' Adds (named or not) package dependencies to a named vector of packages.
#'
#' @param pkgs Processes \code{pkgs}, and \code{locals}, arguments of \code{\link{create_config}} and \code{\link{create_app}}.
#' @param pkg String. Name of package to add
#'
#' @return Package dependency string vector for \code{\link{standardize_pkgs}}.
#'
#' @author Jonathan Hill
#' @export
add_pkg <- function(pkgs, pkg) {

  pkg_strings <- pkg %in% pkgs
  pkg_names <- pkg %in% names(pkgs)

  needed_pkgs <- pkg[!(pkg_names | pkg_strings)]

  if (length(needed_pkgs) > 0) {
    pkgs <- c(pkgs, needed_pkgs)
  }

  return(pkgs)
}
