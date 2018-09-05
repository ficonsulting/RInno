## ---- eval=FALSE---------------------------------------------------------
#  # Require Package
#  require(RInno)
#  
#  # Use RInno to get Inno Setup
#  RInno::install_inno()

## ---- eval=FALSE---------------------------------------------------------
#  # Example app included with RInno package
#  example_app(wd = getwd())
#  
#  # Build an installer
#  create_app(app_name = "Your appname", app_dir = "app")
#  compile_iss()

## ---- eval=FALSE---------------------------------------------------------
#  function(input, output, session) {
#  
#    session$onSessionEnded(function() {
#        stopApp()
#        q("no")
#    })
#  }

## ---- eval=FALSE---------------------------------------------------------
#  create_app(
#    app_name    = "My AppName",
#    app_dir     = "My/app/path",
#    dir_out     = "wizard",
#    pkgs        = c("jsonlite", "shiny", "magrittr", "xkcd"),  # CRAN-like repo packages
#    remotes     = c("talgalili/installr", "daattali/shinyjs"), # GitHub packages
#    include_R   = TRUE,     # Download R and install it with your app, if necessary
#    R_version   = "2.2.1",  # Old versions of R
#    privilege   = "high",   # Admin only installation
#    default_dir = "pf")     # Install app in to Program Files

## ---- eval=FALSE---------------------------------------------------------
#  # Copy installation scripts (JavaScript, icons, infobefore.txt, package_manager.R, app.R)
#  copy_installation(app_dir = "my/app/path")
#  
#  # If your users need R installed:
#  get_R(app_dir = "my/app/path", R_version = 2.2.1)
#  
#  # Create batch file
#  create_bat(app_name = "My AppName", app_dir = "my/app/path")
#  
#  # Create app config file
#  create_config(app_name = "My AppName", R_version = "2.2.1", app_dir = "my/app/path",
#    pkgs = c("jsonlite", "shiny", "magrittr", "dplyr", "caret", "xkcd"))
#  
#  # Build the iss script
#  start_iss(app_name = "My AppName") %>%
#  
#    # C-like directives
#    directives_section(R_version   = "2.2.1",
#               include_R   = TRUE,
#               app_version = "0.1.2",
#               publisher   = "Your Company",
#               main_url    = "yourcompany.com") %>%
#  
#    # Setup Section
#    setup_section(output_dir  = "wizard",
#          app_version = "0.1.2",
#          default_dir = "pf",
#          privilege   = "high",
#          inst_readme = "pre-install instructions.txt",
#          setup_icon  = "myicon.ico",
#          pub_url     = "mycompany.com",
#          sup_url     = "mycompany.github.com/issues",
#          upd_url     = "mycompany.github.com") %>%
#  
#    # Languages Section
#    languages_section() %>%
#  
#    # Tasks Section
#    tasks_section(desktop_icon = FALSE) %>%
#  
#    # Files Section
#    files_section(app_dir = "my/app/path", file_list = "path/to/extra/files") %>%
#  
#    # Icons Section
#    icons_section(app_desc       = "This is my local shiny app",
#          app_icon       = "notdefault.ico",
#          prog_menu_icon = FALSE,
#          desktop_icon   = FALSE) %>%
#  
#    # Execution & Pascal code to check registry during installation
#    # If the user has R, don't give them an extra copy
#    # If the user needs R, give it to them
#    run_section() %>%
#    code_section() %>%
#  
#    # Write the Inno Setup script
#    writeLines(file.path("my/app/path", "My AppName.iss"))
#  
#    # Check your files, then
#    compile_iss()
#  

