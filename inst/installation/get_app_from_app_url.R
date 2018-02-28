get_remote_version <- function(
  app_repo = "none", host = "none",
  auth_user = "none", auth_pw  = "none", auth_token = "none") {

  # Fail early
  if (app_repo == "none") return("none")
  if (class(try(httr::http_error("www.google.com"))) == "try-error") return("none")

  # Method to provide more specific feedback
  warn_user <- function(response) {
    sc <- httr::status_code(response)

    if (sc == 200) {
      return(response)

    } else if (sc == 403) {
      stop("This is a private repo. Provide an authorized user and password to create_config().")
    } else {
      stop("It looks like your username and/or password are incorrect.")
    }
  }

  # Private Repos
  if (auth_pw != "none" | auth_token != "none") {
    if (host == "bitbucket") {
      base_url <-
        sprintf("https://api.bitbucket.org/2.0/repositories/%s/versions",
          app_repo)
      response <- warn_user(
        httr::GET(base_url, httr::authenticate(auth_user, auth_pw)))
      parsed_response <- httr::content(response, "parsed", encoding = "utf-8")
      app_version <- parsed_response$values[[1]]$name
      return(app_version)

    } else if (host == "github") {
      base_url <-
        sprintf("https://api.github.com/repos/%s/releases", app_repo)
      response <- warn_user(
        httr::GET(base_url, httr::authenticate(auth_token, "x-oauth-basic", "basic")))
      parsed_response <- httr::content(response, "parsed", encoding = "utf-8")
      app_version <- parsed_response[[1]]$tag_name
      return(app_version)
    }
  # Public Repos
  } else {
    if (host == "bitbucket") {
      base_url <-
        sprintf("https://api.bitbucket.org/2.0/repositories/%s/versions",
                app_repo)
      response <- warn_user(httr::GET(base_url))
      parsed_response <- httr::content(response, "parsed", encoding = "utf-8")
      app_version <- parsed_response$values[[1]]$name
      return(app_version)

    } else if (host == "github") {
      base_url <-
        sprintf("https://api.github.com/repos/%s/releases", app_repo)
      response <- warn_user(httr::GET(base_url))
      parsed_response <- httr::content(response, "parsed", encoding = "utf-8")
      app_version <- parsed_response[[1]]$tag_name
      return(app_version)
    }
  }
}

api_response <- get_remote_version(
  app_repo   = config$app_repo[[1]],
  host       = config$host[[1]],
  auth_user  = config$auth_user[[1]],
  auth_pw    = config$auth_pw[[1]],
  auth_token = config$auth_token[[1]])

# If information about an app repo has been supplied,
if (api_response != "none") {
  local_version <- try(packageVersion(config$appname[[1]]))

  # A try-error indicates that the package has not been installed
  if (class(local_version) == "try-error") {
    setWinProgressBar(pb, value = 1 / length(pkgs),
                      label = sprintf("Installing %s", config$appname[[1]]))

    if (config$host == "bitbucket") {
      if (config$auth_pw == "none") {
        devtools::install_bitbucket(config$app_repo)
      } else {
        devtools::install_bitbucket(config$app_repo,
          auth_user = config$auth_user, password = config$auth_pw)
      }
    } else if (config$host == "github") {
      if (config$auth_token == "none") {
        devtools::install_github(config$app_repo)
      } else {
        devtools::install_github(config$app_repo, auth_token = config$auth_token)
      }
    }
  } else {
    # Check the version and whether it has been installed, and install it.
    if (local_version != api_response) {
      setWinProgressBar(pb, value = 1 / length(pkgs),
                        label = sprintf("Updating %s to version %s",
                                        config$appname[[1]], api_response))

      if (config$host == "bitbucket") {
        if (config$auth_pw == "none") {
          devtools::install_bitbucket(config$app_repo)
        } else {
          devtools::install_bitbucket(config$app_repo,
            auth_user = config$auth_user, password = config$auth_pw)
        }
      } else if (config$host == "github") {
        if (config$auth_token == "none") {
          devtools::install_github(config$app_repo)
        } else {
          devtools::install_github(config$app_repo, auth_token = config$auth_token)
        }
      }
    }
  }
}
