# RInno v0.0.4.9000
* Added support for flexdashboards. Thanks to HanjoStudy's pull request!

# RInno v0.0.3
* Fixed icon bug
* Added version information for package dependencies
* Added the option to select default browser with `user_browser`
    * Eventually, the user should be able to choose their favorite browser

# RInno v0.0.2
* Added support for GitHub package dependencies
    * Thanks Dean Attali for this feature request
* Fixed `error_log` so that its name can be customized properly
* Cleaned up installation paths
* Added Firefox to the browser search path in `app.R`:
    1. Chrome
    2. Firefox
    3. Internet Explorer
    4. User prompt
* Removed *packages.txt* from installation files. Now using a json array in *utils/config.cfg*

# RInno v0.0.1
* Submitted to CRAN
* Updated LICENSE to conform with GPL-3 standards
* Added DesktopDeployR's Aphache 2.0 copyright notice
* Added Travis-ci, Appveyor, and Codecov to repo
* Added Code of Conduct for contributors

# RInno v0.0.0.9001
* Added a `NEWS.md` file to track changes to the package.
* Built function to install Inno Setup.
* Added support for Bitbucket and GitHub APIs, so that locally deployed shiny apps automatically update during start up sequence.
* Added support for Inno Setup Script sections (start_iss, directives, setup, files, icons, tasks, run, code, and languages), so you can build custom installation wizards in R.
* Added application config file, icons, and installation readme.txt.
* Added package management file which manages a local R library for your shiny app's package dependencies.
* Added error logging
* Modified .onAttach to include information about package version and maintenance
