installed_pkgs = data.frame(installed.packages(applibpath), stringsAsFactors = FALSE)

# Ensure that a package is installed
ensure <- function(pkgs, lib_loc = applibpath) {

  pkg_names <- gsub("_.*", "", basename(pkgs))

  for (i in seq_along(pkgs)) {
    setWinProgressBar(pb,
      value = grep(paste0("\\b", pkg_names[i], "\\b"), pkg_names) / (length(pkg_names) + 1),
      label = sprintf("Loading - %s...", pkg_names[i]))

    if (!pkg_names[i] %in% installed_pkgs$Package) {
      install.packages(pkgs = pkgs[i], lib = lib_loc, repos = NULL, type = "win.binary")
      message(paste0(pkg_names[i], " installed\n"))
    }
  }
}
