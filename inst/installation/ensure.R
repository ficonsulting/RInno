installed_pkgs = data.frame(installed.packages(applibpath), stringsAsFactors = FALSE)

# Ensure that a package is installed
ensure <- function(pkgs, remotes, lib_loc = applibpath) {

  pkg_names <- gsub("_.*", "", basename(pkgs))
  start <- attr(regexpr(".*_", pkgs), "match.length") + 1
  stop <- attr(regexpr(".*", pkgs), "match.length") - 4
  pkg_version <- substr(pkgs, start, stop)

  for (i in seq_along(pkgs)) {
    setWinProgressBar(pb,
      value = grep(paste0("\\b", pkg_names[i], "\\b"), pkg_names) / (length(pkg_names) + 1),
      label = sprintf("Loading - %s...", pkg_names[i]))

    # Get the requirements
    installed_version <- installed_pkgs$Version[installed_pkgs$Package == pkg_names[i]]
    inequality <- ">="

    # Check if the installed version meets the specs
    if (length(installed_version) == 0) {
      specs_not_met <- TRUE
    } else {
      specs_not_met <- !eval(parse(text =
        paste0("numeric_version('", installed_version, "')",
              inequality,
              "numeric_version('", pkg_version[i], "')")))
    }
    if (!pkg_names[i] %in% installed_pkgs$Package | specs_not_met) {
      install.packages(pkgs = pkgs[i], lib = lib_loc, repos = NULL, type = "win.binary")
    }
    message(paste0(pkg_names[i], " installed\n"))
  }

  if (remotes[1] != "none") {
    if (class(try(httr::http_error("www.google.com"))) != "try-error") {
      message("ensuring remotes: ", paste(remotes, collapse = ", "))
      setWinProgressBar(pb, 0, label = "Ensuring remote package dependencies ...")
      ._ <- lapply(remotes, ensure_remotes)
    }
  }

  all_deps <- c(pkg_names, basename(remotes))[!grepl("none", c(pkg_names, remotes))]

  for (i in seq_along(all_deps)) {
    setWinProgressBar(pb,
      value = i / (length(all_deps) + 1),
      label = sprintf("Loading package - %s", all_deps[i]))

    library(all_deps[i], character.only = TRUE)
  }
}

# Ensure that remotes are installed
ensure_remotes <- function(remote, lib_loc = applibpath) {
  pkg_name <- basename(remote)

  setWinProgressBar(pb,
    value = grep(paste0("\\b", pkg_name, "\\b"), remotes) / (length(remotes) + 1),
    label = sprintf("Loading - %s...", pkg_name))

  if (!(pkg_name %in% row.names(installed.packages()))) {
    devtools::install_github(repo = remote, lib = lib_loc, dependencies = TRUE)
  }
  message(paste0(pkg_name, " installed\n"))
}
