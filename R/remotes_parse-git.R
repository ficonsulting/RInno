parse_repo_spec <- function(repo) {
  package_name_rx <- "(?:(?<package>[[:alpha:]][[:alnum:].]*[[:alnum:]])=)?"
  username_rx <- "(?:(?<username>[^/]+)/)"
  repo_rx     <- "(?<repo>[^/@#]+)"
  subdir_rx   <- "(?:/(?<subdir>[^@#]*[^@#/])/?)?"
  ref_rx      <- "(?:@(?<ref>[^*].*))"
  pull_rx     <- "(?:#(?<pull>[0-9]+))"
  release_rx  <- "(?:@(?<release>[*]release))"
  ref_or_pull_or_release_rx <- sprintf(
    "(?:%s|%s|%s)?", ref_rx, pull_rx, release_rx
  )
  spec_rx  <- sprintf(
    "^%s%s%s%s%s$", package_name_rx, username_rx, repo_rx, subdir_rx, ref_or_pull_or_release_rx
  )
  params <- as.list(re_match(text = repo, pattern = spec_rx))

  if (is.na(params$.match)) {
    stop(sprintf("Invalid git repo specification: '%s'", repo))
  }

  params[grepl("^[^\\.]", names(params))]
}

parse_github_repo_spec <- parse_repo_spec

parse_github_url <- function(repo) {
  prefix_rx <- "(?:github[^/:]+[/:])"
  username_rx <- "(?:(?<username>[^/]+)/)"
  repo_rx     <- "(?<repo>[^/@#]+)"
  ref_rx <- "(?:(?:tree|commit|releases/tag)/(?<ref>.+$))"
  pull_rx <- "(?:pull/(?<pull>.+$))"
  release_rx <- "(?:releases/)(?<release>.+$)"
  ref_or_pull_or_release_rx <- sprintf(
    "(?:/(%s|%s|%s))?", ref_rx, pull_rx, release_rx
  )
  url_rx  <- sprintf(
    "%s%s%s%s",
    prefix_rx, username_rx, repo_rx, ref_or_pull_or_release_rx
  )
  params <- as.list(re_match(text = repo, pattern = url_rx))

  if (is.na(params$.match)) {
    stop(sprintf("Invalid GitHub URL: '%s'", repo))
  }
  if (params$ref == "" && params$pull == "" && params$release == "") {
    params$repo <- gsub("\\.git$", "", params$repo)
  }
  if (params$release == "latest") {
    params$release <- "*release"
  }

  params[grepl("^[^\\.]", names(params))]
}

parse_git_repo <- function(repo) {

  if (grepl("^https://github|^git@github", repo)) {
    params <- parse_github_url(repo)
  } else {
    params <- parse_repo_spec(repo)
  }
  params <- params[viapply(params, nchar) > 0]

  if (!is.null(params$pull)) {
    params$ref <- github_pull(params$pull)
    params$pull <- NULL
  }

  if (!is.null(params$release)) {
    params$ref <- github_release()
    params$release <- NULL
  }

  params
}
