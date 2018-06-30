#' @importFrom magrittr %>%
`%>%` <- magrittr::`%>%`

#' Standardize package dependencies
#'
#' Standardizes (named or not) character vectors of package dependencies and formats it for config.cfg.
#'
#' @param pkgs Processes \code{pkgs}, and \code{pkgs}, arguments of \code{\link{create_config}} and \code{\link{create_app}}.
#' @param check_version Boolean. If true, check to make sure the package version is not ahead of CRAN.
#'
#' @return Package dependency list with version numbers and inequalities. Defaults to \code{paste0(">=", packageVersion(pkg))}.
#'
#' @author William Bradley and Jonathan Hill
#' @keywords internal
#' @export
standardize_pkgs <- function(pkgs, check_version = FALSE, string = FALSE) {

  if (pkgs[1] == "none") return("none")

  # remove spaces, create a list and vectors to control the process
  pkgs <- gsub(" ", "", pkgs)
  pkg_list <- as.list(pkgs)
  no_version <- names(pkg_list) == ""
  no_inequality <- !grepl("[<>=]", pkgs)

  # No versions are specified
  if (length(no_version) == 0) {

    tryCatch(
      pkg_list <- lapply(pkg_list, utils::packageVersion),

      error = function(e) {
        stop(e$message,
          "\n\nPlease provide versions of `pkgs` if they are not installed in the development environment.", call. = FALSE)
      })

    names(pkg_list) <- pkgs

    # add greater than or equal to
    pkg_list <- lapply(pkg_list, function(x) paste0(">=", x))

  # Some versions are specified
  } else if (sum(no_version) > 0) {

    tryCatch(
      pkg_list[no_version] <- lapply(pkg_list[no_version], utils::packageVersion),

      error = function(e) {
       stop(e$message, "\n\nPlease provide versions of `pkgs` if they are not installed in the development environment.", call. = FALSE)
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

  check_pkgs <- function(pkg, pkg_name) {
    breakpoint <- attr(regexpr("[<>=]+", pkg), "match.length")
    inequality <- substr(pkg, 1, breakpoint)
    required_version <- substr(pkg, breakpoint + 1, nchar(pkg))

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
      if (numeric_version(required_version) > cran_version(pkg_name)) {
        stop(glue::glue("{pkg_name} v{required_version} is ahead of CRAN - v{cran_version(pkg_name)}. Please add it to `remotes` to use {pkg_name}'s development version from Github/Bitbucket or decrease its version to one published on CRAN."), call. = FALSE)
      }
    }
  }
  mapply(check_pkgs, pkgs, names(pkgs))

  if (string) {
    return(names(pkgs))
  } else {
    return(pkgs)
  }
}


#' Sanitize R's version
#'
#' Used to validate R versions and strip off inequalities when necessary.
#'
#' @inheritParams create_app
#' @param clean Boolean. If TRUE, \code{><=} are removed. Defaults to FALSE.
#' @keywords internal
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


#' Check CRAN for package version
#'
#' @param pkg_name String. Package name as published on CRAN.
#' @param cran_url String. First part of the cannonical form of a package website on CRAN.
#'
#' @return The package's version as a \code{numeric_version}.
#'
#' @examples
#' cran_version("shiny")
#' @keywords internal
#' @export
cran_version = function(pkg_name, cran_url = "http://cran.r-project.org/package=") {

  # Create URL
  cran_pkg_loc = paste0(cran_url, pkg_name)

  # Establish connection
  suppressWarnings(conn <- try(url(cran_pkg_loc), silent = TRUE))

  # If connection, read in webpage
  if (all(class(conn) != "try-error") ) {
    suppressWarnings(cran_pkg_page <- try(readLines(conn), silent = TRUE))
    close(conn)
  } else {
    return(NULL)
  }

  # Use regex to find version info
  version_line = cran_pkg_page[grep("Version:", cran_pkg_page) + 1]
  version_line = gsub("<(td|\\/td)>","",version_line)
  numeric_version(version_line)

}


#' Add package to named vector
#'
#' Adds (named or not) package dependencies to a named vector of packages.
#'
#' @param pkgs Processes \code{pkgs} argument of \code{\link{create_config}} and \code{\link{create_app}}.
#' @param pkg String. Name of package to add
#'
#' @return Package dependency string vector for \code{\link{standardize_pkgs}}.
#'
#' @examples
#' pkgs <- c("shiny", rmarkdown = "1.8", "Rook")
#' add_pkgs(pkgs, c("rmarkdown", "dplyr"))
#'
#' @author Jonathan Hill
#' @keywords internal
#' @export
add_pkgs <- function(pkgs, pkg) {

  pkg_strings <- pkg %in% pkgs
  pkg_names <- pkg %in% names(pkgs)

  needed_pkgs <- pkg[!(pkg_names | pkg_strings)]

  if (length(needed_pkgs) > 0) {
    pkgs <- c(pkgs, needed_pkgs)
  }

  return(pkgs)
}


#' Search for flexdashboard
#'
#' This function locates a flexdashboard within a file list.
#'
#' @param file_list Character vector. List of files within \code{app_dir}.
#'
#' @author Hanjo Odendaal.
#' @keywords internal
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


#' @keywords internal
#' @export
check_app <- function(app_dir, pkgs_path) {
  win_binary_pkgs <- list.files(
    file.path(app_dir, pkgs_path),
    ".zip$"
  )

  mac_binary_pkgs <- list.files(
    file.path(app_dir, pkgs_path),
    ".tgz$"
  )

  if (length(mac_binary_pkgs) > 0) {
    stop(
      "Please build 'win.binary' packages for the following:\n",
      glue::glue("- {mac_binary_pkgs}", .sep = "\n"),
      "\nSee ?install.packages 'Binary packages' for details.\n",
      call. = F
    )
  }

  source_pkgs <- list.files(
    file.path(app_dir, pkgs_path),
    ".tar.gz$"
  )

  if (length(source_pkgs) > 0) {
    stop(
      "Please build 'win.binary' packages for the following:\n",
      glue::glue("- {source_pkgs}", .sep = "\n"),
      "\nSee ?install.packages 'Binary packages' for details.\n",
      call. = F
    )
  }
}

#' @keywords internal
#' @export
check_pkg_version <- function(result) {

  df <- data.frame(result, stringsAsFactors = FALSE)

  names(df) <- c("pkg", "loc")

  df$downloaded_versions <- lapply(
    stringr::str_extract(df$loc, "[0-9]+[\\.-]?[0-9]+[\\.-]?[0-9]*[\\.-]?[0-9]*(?=.zip)"),
    function(x) package_version(x)
  )

  df$installed_versions <- lapply(df$pkg, function(x) packageVersion(x))

  df$different <- is.na(match(df$downloaded_versions, df$installed_versions))

  if (sum(df$different) != 0) {

    df <- df[df$different, ]

    cat(glue::glue("The following installed packages differ from those downloaded from {repo}:"), "\n")
    cat(glue::glue("\n - {df$pkg}, {sapply(df$downloaded_versions, paste0, collapse = '')} (downloaded) vs {sapply(df$installed_versions, paste0, collapse = '')} (installed)\n"), sep = "\n")
  }
}
