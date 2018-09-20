#' Download packages
#'
#' Places package dependencies in \code{pkgs_path}.
#'
#' @inheritParams create_app
#' @export
download_packages <- function(app_dir, pkgs_path, pkgs, repo, remotes, auth_user, auth_token) {

  if (pkgs[[1]] == "none") return(NULL)

  pkgs_path <- file.path(app_dir, pkgs_path)
  if (!dir.exists(pkgs_path)) dir.create(pkgs_path)

  cat("\nGetting package dependencies... \n")

  # Check pkgs class
  if (any(lapply(pkgs, class) != "character")) stop("`pkgs` must be a character vector.", call. = FALSE)

  # Standardize pkgs
  standard_deps <- standardize_pkgs(pkgs)

  # Find all the pkg dependencies
  pkg_deps <- tools::package_dependencies(packages = standard_deps, recursive = TRUE) %>%
    unlist %>% unique

  all_deps <- pkg_deps %>% add_pkgs(standard_deps)

  avail_pkgs <- data.frame(utils::installed.packages(), stringsAsFactors = F)
  base_pkgs <- avail_pkgs[stats::complete.cases(avail_pkgs$Priority), ]
  base_pkgs <- base_pkgs[base_pkgs$Priority == "base", "Package"]

  all_deps_no_base <- all_deps[!all_deps %in% base_pkgs]

  # Figure out which files need to be downloaded
  pkgs_files <- lapply(all_deps_no_base, function(x) list.files(pkgs_path, pattern = paste0("^", x, "_")))
  downloaded_cran_deps <- unlist(lapply(pkgs_files, function(x) if(length(x) >= 1) TRUE else FALSE))
  using_cran <- pkgs_files[downloaded_cran_deps]

  # Let developer know which files are already included
  if (length(using_cran) > 0) {
    cat("\nUsing packages:\n - ")
    cat(file.path(pkgs_path, sort(unlist(using_cran))), sep = "\n - ")
  }

  # Download any required pacakges in app_dir/pkg_path
  req_cran_deps <- all_deps_no_base[!downloaded_cran_deps]
  if (length(req_cran_deps) > 0) {
    cat("\nDownloading required packages...\n")
    utils::download.packages(req_cran_deps, destdir = pkgs_path, repos = repo, type = "win.binary")
  }
  # Validate downloaded packages
  check_pkg_version(pkgs_path, repo)

  if (remotes[1] != "none") {

    pkgs_files <- lapply(remotes, function(x) {
      list.files(pkgs_path, pattern = gsub("[@#].*", "", basename(x)))
    })
    downloaded_remote_deps <- unlist(lapply(pkgs_files, function(x) if(length(x) >= 1) TRUE else FALSE))
    using_remotes <- pkgs_files[downloaded_remote_deps]

    if (length(using_remotes) > 0) {
      cat("Using dowloaded remotes:\n - ")
      cat(file.path(pkgs_path, using_remotes), sep = "\n - ")
    }

    req_remote_deps <- remotes[!downloaded_remote_deps]
    if (length(req_remote_deps) > 0) {
      cat("Downloading remotes... \n - ")
      cat(req_remote_deps, sep = "\n - ")

      github_remotes <- lapply(req_remote_deps, github_remote, username = auth_user,
                        auth_token = auth_token, host = "https://api.github.com")

      zip_files <- lapply(github_remotes, remote_download.github_remote)

      decompressed_pkgs <- lapply(zip_files, function(x) {
        gsub("[\\/]+", "/", source_pkg(x))
      })

      lapply(decompressed_pkgs, pkgbuild::build, dest_path = pkgs_path, binary = TRUE, vignettes = FALSE)
    }
  }
}
