
RInno makes it easy to deploy local shiny apps by providing an interface between R and [Inno Setup](http://www.jrsoftware.org/isinfo.php), an installer for windows programs. It is designed to be simple to use (two lines of code at a minimum), yet comprehensive.

If your client does not have R installed, the RInno's installation wizard will ask them to install it. It also provides a framework for managing R software packages required by your shiny apps and error logging features.

Getting Started
---------------

    # If you don't have development tools, install them
    install.packages('devtools'); require(devtools)

    # Use install_bitbucket to get RInno
    devtools::install_bitbucket(
      repo            = 'fi_consulting/RInno',
      auth_user       = <username>,
      password        = <password>,
      build_vignettes = TRUE)

    # Required Packages
    require(RInno)
    require(installr)
    require(magrittr)
    require(stringr)

    # Use RInno to get Inno Setup
    RInno::install_inno()

If you don't use [installr](https://github.com/talgalili/installr) to update your R version, you should. The next release of installr will include `install_inno` along with a lot of other cool stuff. After that release, `install_inno` will no longer be supported here.

Minimal example
---------------

    # Create an example app in your working directory
    example_app(wd = getwd())

    # Build a deployment
    create_app(app_name = 'Your appname', app_dir = 'app')
    compile_iss()

With simple apps, you should be able to build an installation wizard with `create_app` followed by `compile_iss`.

After you call `create_app`, there will be a lot of new files in your app's directory. Feel free to customize them before you call `compile_iss`. For example, you can replace the default/setup icon at [Flaticon.com](http://www.flaticon.com/), or you can customize the pre-install message in readme.txt. Just remember that the default values for those files have not changed. The .iss script will not know if you create a new icon called "myicon.ico". `compile_iss` will look for "default.ico", so you must replace it.

For custom installations, see below.

server.R Requirements
---------------------

In order to close the app when your user's session completes:

1.  add `session` to your `server` function
2.  call `stopApp()` when the session ends

<!-- -->

    function(input, output, session) {

      session$onSessionEnded(function() {
          stopApp()
          q("no")
      })
    }

Custom Installation Wizards
---------------------------

If you would like create a custom installation wizard from within R, you can slowly build up to it with `create_app`, like this:

    create_app(
      app_name  = 'My AppName', 
      app_dir    = 'My/app/path',
      dir_out   = 'wizard',
      pkgs      = c('jsonlite', 'shiny', 'magrittr', 'xkcd'),
      include_R = TRUE,   # Download R and install it with your app, if necessary
      R_version = 2.2.1,  # Old versions of R
      privilege = 'high', # Admin only installation
      default_dir = 'pf') # Program Files

`create_app` passes its arguments to other functions, so you can specify most things there or provide detailed instructions directly to those functions like this:

    # Copy deployment scripts (JavaScript, icons, readme.txt, run.R, app.R)
    copy_deployment(app_dir = 'my/app/path')

    # If your users need R installed:
    get_R_exe(
      app_dir    = 'my/app/path', 
      R_version = 2.2.1)

    # Create batch file
    create_bat(app_name = 'My AppName', app_dir = 'my/app/path')

    # Create app config file
    create_config(
      app_name = 'My AppName', 
      R_version = 2.2.1, 
      app_dir = 'my/app/path')

    # Create package dependency list
    create_pkgs(
      pkgs = c('jsonlite', 'shiny', 'magrittr', 'dplyr', 'caret', 'xkcd'), 
      app_dir = 'my/app/path')

    # Build the iss script
    start_iss(app_name = 'My AppName') %>%

      # C-like directives
      directives(R_version   = 2.2.1, 
                 include_R   = TRUE, 
                 app_version = '0.1.2',
                 publisher   = 'Your Company', 
                 main_url    = 'yourcompany.com') %>%

      # Setup Section
      setup(output_dir  = 'wizard', 
            app_version = 2.2.1,
            default_dir = 'pf', 
            privilege   = 'high',
            inst_readme = 'pre-install instructions.txt', 
            setup_icon  = 'myicon.ico',
            pub_url     = 'mycompany.com', 
            sup_url     = 'mycompany.github.com/issues',
            upd_url     = 'mycompany.github.com') %>%

      # Languages Section
      languages() %>%

      # Tasks Section
      tasks(desktop_icon = FALSE) %>%

      # Files Section
      files(app_dir = 'my/app/path', file_list = 'path/to/extra/files') %>%

      # Icons Section
      icons(app_desc       = 'This is my local shiny app',
            app_icon       = 'notdefault.ico',
            prog_menu_icon = FALSE,
            desktop_icon   = FALSE) %>%

      # Execution & Pascal code to check registry during installation
      # If the user has R, don't give them an extra copy
      # If the user needs R, give it to them
      run() %>%
      code() %>%

      # Write the Inno Setup script
      writeLines(file.path('my/app/path', 'My AppName.iss'))

      # Check your files, then
      compile_iss()

Feel free to read the Inno Setup [documentation](http://www.jrsoftware.org/ishelp/) and RInno's documentation to get a sense for what is possible. Please also suggest useful features or build them yourself!