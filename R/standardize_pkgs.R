#' Standardize package dependencies
#'
#' Standardizes (named or not) character vectors of package dependencies and formats it for config.cfg.
#'
#' @param pkgs Processes \code{pkgs}, and \code{locals}, arguments of \code{\link{create_config}} and \code{\link{create_app}}.
#' @param check_version Boolean. If true, check to make sure the package version is not ahead of CRAN.
#'
#' @return Package dependency list with version numbers and inequalities. Defaults to \code{paste0(">=", packageVersion(pkg))}.
#'
#' @author William Bradley and Jonathan Hill
#' @export

standardize_pkgs <- function(pkgs, check_version = FALSE) {

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
  installed_pkgs <- data.frame(utils::installed.packages(), row.names = NULL)
  if (check_version) {
    cran_pkgs <- tools::CRAN_package_db()
  }
  check_pkgs <- function(pkg, pkg_name) {
    breakpoint <- attr(regexpr("[<>=]+", pkg), "match.length")
    inequality <- substr(pkg, 1, breakpoint)
    required_version <- substr(pkg, breakpoint + 1, nchar(pkg))
    cran_version <- cran_pkgs$Version[cran_pkgs$Package == pkg_name]

    if (nchar(inequality) > 2 | grepl("=[<>]", inequality)) {
      stop(glue::glue("{pkg_name}'s inequality ({inequality}) is not a valid logical operator"), call. = F)
    }
    if (class(try(numeric_version(required_version), silent = TRUE)) == "try-error") {
      stop(glue::glue("{required_version} is not a valid `numeric_version` for {pkg_name} "), call. = F)
    }
    if (!pkg_name %in% installed_pkgs$Package) {
      stop(glue::glue("{pkg_name} is not installed. Make sure it is in `installed.pacakges()` and try again."), call. = F)
    }
    if (check_version) {
      if (numeric_version(required_version) > numeric_version(cran_version)) {
        stop(glue::glue("{pkg_name} v{required_version} is ahead of CRAN - v{cran_version}. Please add it to `remotes` to use {pkg_name}'s development version from Github/Bitbucket or decrease its version to one published on CRAN."), call. = FALSE)
      }
    }
  }
  mapply(check_pkgs, pkgs, names(pkgs))

  return(pkgs)
}

#' Sanitize R's version
#'
#' Used to validate R versions and strip off inequalities when necessary.
#'
#' @inheritParams create_app
#' @param clean Boolean. If TRUE, \code{><=} are removed. Defaults to FALSE.
#' @export
sanitize_R_version <- function(R_version, clean = FALSE){

  # Check for valid R version
  test <- gsub("[<>=[:space:]]", "", R_version)
  if (any(length(strsplit(test, "\\.")[[1]]) != 3,
          !grepl("[1-3]\\.[0-9]+\\.[0-9]+", test))) {
    stop(glue::glue("R_version ({test}) is not valid."), call. = FALSE)
  }

  # Remove spaces
  R_version <- gsub(" ", "", R_version)

  # Check the inequality
  if (grepl("[<>=]", R_version)) {
    breakpoint <- attr(regexpr("[<>=]+", R_version), "match.length")
    inequality <- substr(R_version, 1, breakpoint)
    if (grepl("=[<>]", inequality)) {
      stop(glue::glue("R_version's inequality, {inequality}, is not a valid logical operator"), call. = FALSE)
    } else if (nchar(inequality) == 1) {
      stop(glue::glue("RInno only supports >=, <= and == in R_version"), call. = FALSE)
    } else if (breakpoint > 2) {
      stop(glue::glue("R_version = {R_version} is not supported."), call. = FALSE)
    }

  } else {
    # add == if no inequality is specified
    R_version <- paste0(">=", R_version)
  }
  if (clean) R_version <- gsub("[<>=[:space:]]", "", R_version)
  return(R_version)
}
