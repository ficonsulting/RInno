installed_pkgs = data.frame(installed.packages())

# Ensure that a package is installed
ensure <- function(pkg, pkg_name, repo = config$pkgs$cran) {

  setWinProgressBar(pb,
    value = grep(paste0("\\b", pkg_name, "\\b"), names(pkgs)) / (length(pkgs) + 1),
    label = sprintf("Loading - %s...", pkg_name))

  # Get the CRAN version & requirements
  cran_version <- pkgVersionCRAN(pkg_name)
  installed_version <- installed_pkgs$Version[installed_pkgs$Package == pkg_name]
  breakpoint <- attr(regexpr("[<>=]+", pkg), "match.length")
  inequality <- substr(pkg, 1, breakpoint)
  required_version <- substr(pkg, breakpoint + 1, nchar(pkg))

  # Check if the installed version meets the specs
  if (length(installed_version) == 0) {
    specs_not_met <- TRUE
  } else {
    specs_not_met <- !eval(parse(text =
      paste0("numeric_version('", installed_version, "')",
             inequality,
             "numeric_version('", required_version, "')")))
  }

  # Check if package is installed and the specs are met
  if (!pkg_name %in% installed_pkgs$Package | specs_not_met) {
    if (cran_version == required_version) {
      devtools::install_cran(pkg_name, repos = repo, dependencies = TRUE)
    } else {
      devtools::install_version(pkg_name, version = required_version, repos = repo, dependencies = TRUE)
    }
  }
  library(pkg_name, character.only = TRUE)
  message(paste0(pkg_name, " installed\n"))
}

# Ensure that remotes are installed
ensure_remotes <- function(remote) {
  setWinProgressBar(pb,
    value = grep(paste0("\\b", remote, "\\b"), remotes) / (length(remotes) + 1),
    label = sprintf("Loading - %s...", remote))
  pkg <- basename(remote)
  if (!(pkg %in% row.names(installed.packages()))) {
    devtools::install_github(remote, dependencies = TRUE)
  }
  library(pkg, character.only = TRUE)
  message(paste0(pkg_name, " installed\n"))
}

# Ensures local packages are installed
ensure_local <- function(pkg, pkg_name, lib_path = file.path(appwd, config$locals$local)) {
  setWinProgressBar(pb,
    value = grep(paste0("\\b", pkg_name, "\\b"), names(locals)) / (length(locals) + 1),
    label = sprintf("Loading - %s...", pkg_name))

  # Get the requirements
  installed_version <- installed_pkgs$Version[installed_pkgs$Package == pkg_name]
  breakpoint <- attr(regexpr("[<>=]+", pkg), "match.length")
  inequality <- substr(pkg, 1, breakpoint)
  required_version <- substr(pkg, breakpoint + 1, nchar(pkg))

  # Check if the installed version meets the specs
  if (length(installed_version) == 0) {
    specs_not_met <- TRUE
  } else {
    specs_not_met <- !eval(parse(text =
      paste0("numeric_version('", installed_version, "')",
             inequality,
             "numeric_version('", required_version, "')")))
  }
  if (!pkg_name %in% installed_pkgs$Package | specs_not_met) {
    install.packages(list.files(path = lib_path, pattern = pkg_name, full.names = T), repos = NULL, type = "source")
  }
  library(pkg_name, character.only = TRUE)
  message(paste0(pkg_name, " installed\n"))
}

# Internet connection test
ping_site <- function(site_url) {
  !as.logical(system(paste("ping -n 1", site_url)))
}

# Check CRAN if package version is current
pkgVersionCRAN = function(pkg_name, cran_url = "http://cran.r-project.org/package=") {

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
