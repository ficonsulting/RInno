# RInno v0.1.2
* Swapped out many `sprintf` calls with RStudio's new `glue` function for interpolating strings. This should make RInno more flexible and easier to maintain and debug moving forward.
* Added support for app mode when `user_browser = "chrome"`. RInno also automatically places `app_icon` in a "www/" directory and utilizes port 1984. This makes it easy to display the app's icon instead of Chrome's (see README for details). Big shout out to [@trybik](https://github.com/trybik) for this great suggestion.
* Created an option to include an installation of Chrome with the app's installer w/ `include_Chrome = TRUE`.
* Improved handling of internet connection status. If the app has never started before, it will stop and tell users to check their internet connection and try again. Otherwise, the app will start normally, but the app's log will have information about the fact that it pinged www.google.com and did not get a response. Thank you [@zhengle-advantaseeds](https://github.com/zhengle-advantaseeds) for reporting this issue! [#22](https://github.com/ficonsulting/RInno/issues/22)
* Exposed R installation flags w/ the `R_flags` argument. For more information, read `?run`. Thanks [@renejuan](https://github.com/renejuan) for requesting this feature!

# RInno v0.1.1
* Patched the way that RInno handles icons and text files. The defaults no longer cause Inno Setup compilation errors when custom icons or messaging is provided. Thanks [@sollano](https://github.com/sollano) for uncovering this bug!
* Fixed the private repo process for continuous installations from Github. Added a new argument `auth_token`, which uses a [Github token](https://github.com/settings/tokens) to authenticate with private repos. [@sollano](https://github.com/sollano) again provided amazingly detailed information that helped us resolve this issue. [#19](https://github.com/ficonsulting/RInno/issues/19)

# RInno v0.1.0
* Major improvements to registry checks and app start up sequence
    * RInno installers now query the registry during installation so that local Shiny apps can use registry information during their startup sequence. The registry is queried for R, Pandoc, Chrome, Firefox, and Internet Explorer. If you would like any other software added to the regpaths.json output, give us a holler!
    * This should make Shiny apps installed with RInno reliable for large numbers of users because strange installation bugs are often caused by unique desktop setups. RInno v0.1.0 should reduce the maintenance cost of local installations and make them scalable for medium-sized organizations and teams.
* Hanjo Odendall ([@HanjoStudy](https://github.com/HanjoStudy)) added support for [flexdashboards](http://rmarkdown.rstudio.com/flexdashboard/). Thanks Hanjo!
    * Similar to the way that RInno installers can include copies of R, they can now include a copy of Pandoc to support the installation of flexdashboards. Because the registry query (detailed above) is performed post-install, these installation paths are captured by the registry query and can be used in the app startup sequence.
* Our next release in September - October should include support for OAuth2 for RInno apps using continuous installation.

# RInno v0.0.3
* Fixed icon bug
* Added version information for package dependencies
* Added the option to select default browser with `user_browser`
    * Eventually, the user should be able to choose their favorite browser

# RInno v0.0.2
* Added support for GitHub package dependencies
    * Thanks Dean Attali ([@daattali](https://github.com/daattali/)) for this feature request
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
