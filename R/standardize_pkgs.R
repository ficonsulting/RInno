#' Standardize package dependencies
#'
#' Standardizes (named or not) character vectors of package dependencies. This creates a standard format for package dependency information stored in config.cfg
#'
#' @param pkgs Processes \code{pkgs}, and \code{locals}, arguments of \code{\link{create_config}} and \code{\link{create_app}}.
#'
#' @return Package dependency list with version numbers and inequalities. Defaults to \code{paste0(">=", packageVersion(pkg))}.
#'
#' @author William Bradley and Jonathan Hill

standardize_pkgs <- function(pkgs) {

  if (pkgs[1] == "none") return("none")

  # remove spaces, create a list and vectors to control the process
  pkgs <- gsub(" ", "", pkgs)
  pkg_list <- as.list(pkgs)
  no_version <- names(pkg_list) == ""
  no_inequality <- !grepl("[<>=]", pkgs)

  # No versions are specified
  if (length(no_version) == 0) {

    tryCatch(pkg_list <- lapply(pkg_list, utils::packageVersion),
      error = function(e) {
        stop(e$message, "\n\nPlease provide versions of `pkgs` and `locals` if they are not installed in the development environment.", call. = FALSE)
    })

    names(pkg_list) <- pkgs

    # add greater than or equal to
    pkg_list <- lapply(pkg_list, function(x) paste0(">=", x))

  # Some versions are specified
  } else if (sum(no_version) > 0) {

    tryCatch(pkg_list[no_version] <- lapply(pkg_list[no_version], utils::packageVersion),
      error = function(e) {
        stop(e$message, "\n\nPlease provide versions of `pkgs` and `locals` if they are not installed in the development environment.", call. = FALSE)
    })

    names(pkg_list)[no_version] <- pkgs[no_version]

    # add greater than or equal to
    pkg_list[no_inequality] <- lapply(pkg_list[no_inequality], function(x) paste0(">=", x))

  # All versions are specified
  } else {
    # add greater than or equal to
    pkg_list[no_inequality] <- lapply(pkg_list[no_inequality], function(x) paste0(">=", x))
  }

  # convert to character for JSON
  pkgs <- lapply(pkg_list, as.character)

  # Make sure the results are valid
  check_pkgs <- function(pkg, pkg_name) {
    breakpoint <- attr(regexpr("[<>=]+", pkg), "match.length")
    inequality <- substr(pkg, 1, breakpoint)
    required_version <- substr(pkg, breakpoint + 1, nchar(pkg))

    if (nchar(inequality) > 2 | grepl("=[<>]", inequality)) {
      stop(glue::glue("{inequality} for {pkg_name} is not a valid logical operator"), call. = F)
    }
    if (class(try(numeric_version(required_version))) == "try-error") {
      stop(glue::glue("{required_version} for {pkg_name} is not a valid `numeric_version`"), call. = F)
    }
  }
  mapply(check_pkgs, pkg_list, names(pkg_list))

  return(pkgs)
}
