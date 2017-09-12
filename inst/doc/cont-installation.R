## ---- eval=FALSE---------------------------------------------------------
#  create_app(
#    app_name     = "myapp",
#    app_repo_url = "https://bitbucket.org/fi_consulting/myapp",
#    pkgs         = c("magrittr", "httr", "shiny", "myapp"),
#    auth_user    = "<read_only_username>",
#    auth_pw      = "<password>")
#  
#  compile_iss()

## ---- eval=FALSE---------------------------------------------------------
#  create_config(
#    app_name     = "myapp",
#    R_version    = "3.3.2",
#    app_dir      = "app",
#    pkgs         = c("magrittr", "httr", "shiny", "myapp"),
#    app_repo_url = "https://bitbucket.org/fi_consulting/myapp",
#    auth_user    = "<read_only_username>",
#    auth_pw      = "<password>")
#  
#  # -------------------------------------------------- Many steps later
#  compile_iss()

## ---- eval=FALSE---------------------------------------------------------
#  create_app(
#    app_name     = "myapp",
#    app_repo_url = "https://github.com/fi_consulting/myapp",
#    pkgs         = c("magrittr", "httr", "shiny", "myapp"),
#    auth_token   = "<app_token>")
#  
#  compile_iss()

## ---- eval=FALSE---------------------------------------------------------
#  create_config(
#    app_name     = "myapp",
#    R_version    = "3.3.2",
#    app_dir      = "app",
#    app_repo_url = "https://github.com/fi_consulting/myapp",
#    pkgs         = c("magrittr", "httr", "shiny", "myapp"),
#    auth_token   = "<app_token>")
#  
#  # -------------------------------------------------- Many steps later
#  compile_iss()

## ------------------------------------------------------------------------
numeric_version("0.1.0") == numeric_version("0.1")

## ------------------------------------------------------------------------
# First release!
numeric_version("0.0.1") > numeric_version("0.0.0.9000")

