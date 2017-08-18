# Ensure that a package is installed and up to date
ensure <- function(pkg, repo = config$pkgs$cran, load = TRUE) {
  setWinProgressBar(pb,
    value = grep(paste0("\\b", pkg, "\\b"), pkgs) / (length(pkgs) + 1),
    label = sprintf("Loading - %s...", pkg))

  if (!(pkg %in% row.names(installed.packages()))) {
    install.packages(pkg, repo = repo, lib = applibpath)
  }
  if (as.character(utils::packageVersion(pkg)) != cran_pkg_version(pkg)) {
    install.packages(pkg, repo = repo, lib = applibpath)
  }
  if (load) {
    library(pkg, character.only = TRUE)
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

# Helper to check CRAN package version
cran_pkg_version <- function(pkg,
  cran_url = "http://cran.r-project.org/web/packages/") {

  cran_pkg_loc = paste0(cran_url,pkg)

  # Try to establish a connection
  suppressWarnings(conn <- try(url(cran_pkg_loc), silent = TRUE))

  # If connection, try to parse values, otherwise return NULL
  if (all(class(conn) != "try-error")) {
    suppressWarnings(cran_pkg_page <- try(readLines(conn), silent = TRUE))
    close(conn)
  } else {
    return(NULL)
  }

  # Extract version info
  version_line = cran_pkg_page[grep("Version:", cran_pkg_page) + 1]
  gsub("<(td|\\/td)>", "", version_line)
}
