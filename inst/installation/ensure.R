# Check CRAN if package version is current

pkgVersionCRAN = function(pkg_name, cran_url="http://cran.r-project.org/package=") {

  # Create URL
  cran_pkg_loc = paste0(cran_url,pkg_name)

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
  gsub("<(td|\\/td)>","",version_line)

}

# Ensure that a package is installed

ensure <- function(pkg, pkg_name, repo = config$pkgs$cran, load = TRUE) {

  # Check if package is the most recent version
  curr_vrsn <- pkgVersionCRAN(pkg_name)

  # Check if package is in installed.packages
  if (!pkg_name %in% row.names(installed.packages())) {
    if (curr_vrsn == pkg) {
      install.packages(pkg_name, repos = repo)
    } else {
      devtools::install_version(pkg_name, version = pkg, repos = repo)
    }
  }

  # Check if version matches
  if (packageVersion(pkg_name) != pkg) {
    if (curr_vrsn == pkg) {
      install.packages(pkg_name, repos = repo)
    } else {
      devtools::install_version(pkg_name, version = pkg, repos = repo)
    }
  }

  if (load) {
    library(pkg_name, character.only = TRUE)
  }

}

# Ensure that remotes are installed
ensure_remotes <- function(remote) {
  setWinProgressBar(pb,
    value = grep(paste0("\\b", remote, "\\b"), remotes) / (length(remotes) + 1),
    label = sprintf("Loading - %s...", remote))
  pkg <- basename(remote)
  if (!(pkg %in% row.names(installed.packages()))) {
    devtools::install_github(remote)
  }
  library(pkg, character.only = TRUE)
}

# Ensures local packages are installed
ensure_local <- function(pkg, pkg_name, lib.path) {
  setWinProgressBar(pb,
    value = grep(paste0("\\b", pkg, "\\b"), locals) / (length(locals) + 1),
    label = sprintf("Loading - %s...", pkg_name))
  if (!(pkg_name %in% row.names(installed.packages())) || (utils::packageVersion(pkg_name) != pkg)) {
    install.packages(
      list.files(lib.path, pattern = pkg_name, full.names = TRUE),
      repos = NULL,
      type = "source")
  }
  library(pkg_name, character.only = TRUE)
}

# Internet connection test
ping_site <- function(site_url) {
  !as.logical(system(paste("ping -n 1", site_url)))
}
