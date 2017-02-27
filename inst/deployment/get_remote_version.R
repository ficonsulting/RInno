get_remote_version <- function(
  app_repo = 'none', host = 'none', auth_user = 'none', auth_pw  = 'none') {

  # Fail early
  if (app_repo == 'none') return('none')

  # Method to provide more specific feedback
  warn_user <- function(response) {
    sc <- httr::status_code(response)

    if (sc == 200) {
      return(response)

    } else if (sc == 403) {
      stop('This is a private repo. Provide an authorized user and password to create_config().')
    } else {
      stop('It looks like your username and/or password are incorrect.')
    }
  }

  # Private Repos
  if (auth_pw != 'none') {
    if (host == 'bitbucket') {
      base_url <-
        sprintf('https://api.bitbucket.org/2.0/repositories/%s/versions',
          app_repo)
      response <- warn_user(
        httr::GET(base_url, httr::authenticate(auth_user, auth_pw)))
      parsed_response <- httr::content(response, 'parsed', encoding = 'utf-8')
      app_version <- parsed_response$values[[1]]$name
      return(app_version)

    } else if (host == 'github') {
      base_url <-
        sprintf('https://api.github.com/repos/%s/releases', app_repo)
      response <- warn_user(
        httr::GET(base_url, httr::authenticate(auth_user, auth_pw)))
      parsed_response <- httr::content(response, 'parsed', encoding = 'utf-8')
      app_version <- parsed_response[[1]]$tag_name
      return(app_version)
    }
  # Public Repos
  } else {
    if (host == 'bitbucket') {
      base_url <-
        sprintf('https://api.bitbucket.org/2.0/repositories/%s/versions',
                app_repo)
      response <- warn_user(httr::GET(base_url))
      parsed_response <- httr::content(response, 'parsed', encoding = 'utf-8')
      app_version <- parsed_response$values[[1]]$name
      return(app_version)

    } else if (host == 'github') {
      base_url <-
        sprintf('https://api.github.com/repos/%s/releases', app_repo)
      response <- warn_user(httr::GET(base_url))
      parsed_response <- httr::content(response, 'parsed', encoding = 'utf-8')
      app_version <- parsed_response[[1]]$tag_name
      return(app_version)
    }
  }
}



