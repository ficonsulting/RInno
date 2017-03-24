# Ensure that a package is installed
ensure <- function(pkg, repo = config$pkgs$cran, load = TRUE) {
  setWinProgressBar(pb,
    value = grep(paste0("\\b", pkg, "\\b"), pkgs) / (length(pkgs) + 1),
    label = sprintf("Loading - %s...", pkg))

  if (!(pkg %in% row.names(installed.packages()))) {
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
