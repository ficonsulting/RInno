# RInno v0.1.0
* Major improvements to registry checks and app start up sequence!
    * RInno installers now query the registry during installation so that local Shiny apps can use its installation path information during their startup sequence. The registry is queried for R, Pandoc, Chrome, Firefox, and Internet Explorer. If you would like any other software added to the regpaths.json output, give us a holler!
    * This should make Shiny apps installed with RInno reliable for large numbers of users because the more users you support, the more time you often spend handling strange installation bugs. RInno v0.1.0 should reduce that cost and make local installations scalable for medium to large organizations.
* Hanjo Odendall also added support for flexdashboards. Thanks to Hanjo!
    * Similar to the way that RInno installers can include copies of R, they can also include a copy of Pandoc to support the installation of flexdashboards. Because the registry query is performed post-install, these installation paths are captured by the registry query and can be used in the app startup sequence.

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
