#' magrittr Pipes
#'
#' @importFrom magrittr %>%
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @seealso \code{\link[magrittr]{magrittr}}
#' @export
`%>%` <- magrittr::`%>%`

#' Standardize package dependencies
#'
#' Standardizes (named or not) character vectors of package dependencies and formats it for config.cfg.
#'
#' @param pkgs Processes \code{pkgs}, and \code{pkgs}, arguments of \code{\link{create_config}} and \code{\link{create_app}}.
#'
#' @return Package dependency list
#'
#' @author William Bradley and Jonathan Hill
#' @keywords internal
#' @export
standardize_pkgs <- function(pkgs) {

  if (pkgs[1] == "none") return("none")

  # deprecation message
  if (!is.null(names(pkgs))) {
    warning("Package versions are no longer supported. Please develop your app using the most recent CRAN version.", call. = FALSE)

    version <- names(pkgs) != ""

    if (length(version) != 0) {
      pkgs[version] <- names(pkgs[version])
    }
  }

  # Make sure pkgs are installed
  installed_pkgs <- data.frame(utils::installed.packages(), row.names = NULL, stringsAsFactors = FALSE)
  missing_pkgs <- !pkgs %in% installed_pkgs$Package
  if (any(missing_pkgs)) {
    stop(glue::glue("{pkgs[missing_pkgs]} is not installed. Please install it and try again."), call. = FALSE)
  }

  names(pkgs) <- NULL

  return(pkgs)
}


#' Sanitize R's version
#'
#' Used to validate R version, strip whitespaces and, optionally, to stripp off
#' leading inequalities.
#'
#' @inheritParams create_app
#' @param clean Boolean. If TRUE, \code{><=} are removed. Defaults to FALSE.
#' @param R_version_min Minimal supported R version. If \code{NULL} check won't
#'   be done. Default value is \code{"3.0.2"}.
#' @keywords internal
#' @export
sanitize_R_version <- function(R_version, clean = FALSE, R_version_min = "3.0.2"){

  # Remove spaces
  R_version <- gsub(" ", "", R_version)

  # Check for valid R version
  test <- gsub("^[<>=]+", "", R_version)
  test_vec <- strsplit(test, "\\.")[[1]]
  # add patchlevel version "0" if none given
  if (length(test_vec) < 3) test_vec[3] = "0"
  test.full <- paste(test_vec, collapse = ".")
  R_version <- gsub(test, test.full, R_version)
  rsv <- tryCatch(R_system_version(test.full),
    error = function(e) stop(glue::glue("R_version ({test}) is not valid."), call. = FALSE))
  # Check for minimal supported R version
  if (!is.null(R_version_min) && rsv < R_version_min) {
    stop(glue::glue("R_version ({test}) <= {R_version_min} is not supported."), call. = FALSE)
  }

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
    # add >= if no inequality is specified
    R_version <- paste0(">=", R_version)
  }
  if (clean) R_version <- gsub("[<>=]", "", R_version)
  return(R_version)
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

  needed_pkgs <- pkg[!pkg %in% pkgs]

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
check_pkg_version <- function(pkgs_path, repo) {

  binary <- data.frame(loc = list.files(pkgs_path, full.names = TRUE), stringsAsFactors = FALSE)
  binary$pkg <- gsub("_.*", "", basename(binary$loc))
  binary$downloaded_versions <- gsub("-", "\\.", stringr::str_extract(binary$loc, "[0-9]+[\\.-]?[0-9]+[\\.-]?[0-9]*[\\.-]?[0-9]*(?=.zip)"))

  # Validate successful downloads
  for (loc in binary$loc) {
    tryCatch(

      expr = utils::unzip(loc, list = TRUE),

      error = function (e) {
        pkg <- binary$pkg[binary$loc == loc]
        file.remove(loc)
        utils::download.packages(pkg, destdir = pkgs_path, repos = repo, type = "win.binary")
      }
    )
  }

  binary$installed_versions <- unlist(lapply(binary$pkg, function(x) toString(utils::packageVersion(x))))

  binary$different <- binary$downloaded_versions != binary$installed_versions

  if (sum(binary$different) != 0) {

    binary <- binary[binary$different, ]

    cat(glue::glue("\n\nThe following installed packages differ from those downloaded from {repo}:"), "\n")
    cat(glue::glue("\n - {binary$pkg}: \t{sapply(binary$downloaded_versions, paste0, collapse = '')} (downloaded) \t{sapply(binary$installed_versions, paste0, collapse = '')} (installed)\n\n"), sep = "\n")

    ans <- utils::menu(title = "It is recommended that you update these packages. Would you like to do so now?", choices = c("Yes", "No"))

    if (ans == 1) {
      utils::update.packages()
      cat("\n\nYou should re-run and test your app to confirm that the updated packages work correctly. \n")
    }
  }
}

#' @keywords internal
node_exists <- function(npm = TRUE) {
  tryCatch(
    {
      system("node -v", intern = TRUE)
      if (npm) system("npm -v", intern = TRUE)
      return(TRUE)
    },
    error = function(e) {
      return(FALSE)
    }
  )
}

#' @keywords internal
reset_formals <- function(fun) {
  for (formal in names(formals(fun))) {
    if (length(get(formal, envir = parent.frame())) == 0) assign(formal, formals(fun)[formal], envir = parent.frame())
  }
}

