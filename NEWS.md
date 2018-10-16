# RInno 1.0.0
* Huge shout out to [@trybik](https://github.com/trybik) for contributing multiple pull requests and having the vision to move towards a stand-alone Electron UI.
* We're now using [nativefier](https://github.com/jiahaog/nativefier) to produce an Electron desktop app for shiny.
* Many options will be deprecated in the next release. We're putting out notices in this release, so complain loudly if you want to keep `user_browser = "chrome"` or other options that are inferior to `user_browser = "electron"`.

## Breaking Change
* Package dependency versions are temporarily not supported. Moving towards a self-contained application with windows binaries of all dependencies (CRAN, Github, Bitbucket, etc.). This makes it easier for IT to create a security rule for the .exe, and removes the need for an internet connection to install dependencies from CRAN and Github/Bitbucket. They all come in one package together.

# RInno 0.2.1
* Numerous bug fixes over the past 6 months
* Big shout outs to [@bthomasbailey](https://github.com/bthomasbailey), [@chasemc](https://github.com/chasemc), [@trybik](https://github.com/trybik) and [@Laurae2](https://github.com/Laurae2) for their pull requests and support of the project's issue submissions.
* Roled back `--app` tag for Chrome in preparation for a true stand-alone release using the Electron framework (0.3.0). We will focus on that instead of the numerous issues caused by running Chrome in app mode.

# RInno 0.2.0
* [@zhengle-advantaseeds](https://github.com/zhengle-advantaseeds) and [@trybik](https://github.com/trybik) continue to move the project forward with great ideas and bug fixes.
* [@willbradley](https://github.com/willbradley) created a pull request which adds support for package version control and local package installations [#34](https://github.com/ficonsulting/RInno/issues/34). Conditional statements like `shiny = ">= 1.0.5"` and/or local .tar.gz of R packages are now supported. These can reduce software dependency bugs caused by updates to CRAN.
* Added support for more flexible R-version checks - [#24](https://github.com/ficonsulting/RInno/issues/24).
* For users who use support functions (i.e. `setup`, `files`, `code` etc.), this version includes breaking changes. All of those functions have been appended with `_section` in order to avoid namespace conflicts with `devtools::setup` and `shiny::code` among others.

# RInno 0.1.2
* Swapped out many `sprintf` calls with RStudio's new `glue` function for interpolating strings. This should make RInno more flexible and easier to maintain and debug moving forward.
* Added support for app mode when `user_browser = "chrome"`. RInno also automatically places `app_icon` in a "www/" directory and utilizes port 1984. This makes it easy to display the app's icon instead of Chrome's (see README for details). Big shout out to [@trybik](https://github.com/trybik) for this great suggestion.
* Created an option to include an installation of Chrome with the app's installer w/ `include_Chrome = TRUE`.
* Improved handling of internet connection status. If the app has never started before, it will stop and tell users to check their internet connection and try again. Otherwise, the app will start normally, but the app's log will have information about the fact that it pinged www.google.com and did not get a response. Thank you [@zhengle-advantaseeds](https://github.com/zhengle-advantaseeds) for reporting this issue! [#22](https://github.com/ficonsulting/RInno/issues/22)
* Exposed R installation flags w/ the `R_flags` argument. For more information, read `?run`. Thanks [@renejuan](https://github.com/renejuan) for requesting this feature!

# RInno 0.1.1
* Patched the way that RInno handles icons and text files. The defaults no longer cause Inno Setup compilation errors when custom icons or messaging is provided. Thanks [@sollano](https://github.com/sollano) for uncovering this bug!
* Fixed the private repo process for continuous installations from Github. Added a new argument `auth_token`, which uses a [Github token](https://github.com/settings/tokens) to authenticate with private repos. [@sollano](https://github.com/sollano) again provided amazingly detailed information that helped us resolve this issue. [#19](https://github.com/ficonsulting/RInno/issues/19)

# RInno 0.1.0
* Major improvements to registry checks and app start up sequence
    * RInno installers now query the registry during installation so that local Shiny apps can use registry information during their startup sequence. The registry is queried for R, Pandoc, Chrome, Firefox, and Internet Explorer. If you would like any other software added to the regpaths.json output, give us a holler!
    * This should make Shiny apps installed with RInno reliable for large numbers of users because strange installation bugs are often caused by unique desktop setups. 0.1.0 should reduce the maintenance cost of local installations and make them scalable for medium-sized organizations and teams.
* Hanjo Odendall ([@HanjoStudy](https://github.com/HanjoStudy)) added support for [flexdashboards](http://rmarkdown.rstudio.com/flexdashboard/). Thanks Hanjo!
    * Similar to the way that RInno installers can include copies of R, they can now include a copy of Pandoc to support the installation of flexdashboards. Because the registry query (detailed above) is performed post-install, these installation paths are captured by the registry query and can be used in the app startup sequence.
* Our next release in September - October should include support for OAuth2 for RInno apps using continuous installation.

# RInno 0.0.3
* Fixed icon bug
* Added version information for package dependencies
* Added the option to select default browser with `user_browser`
    * Eventually, the user should be able to choose their favorite browser

# RInno 0.0.2
* Added support for GitHub package dependencies
    * Thanks Dean Attali ([@daattali](https://github.com/daattali/)) for this feature request
* Fixed `error_log` so that its name can be customized properly
* Cleaned up installation paths
* Added Firefox to the browser search path in `launch_app.R`:
    1. Chrome
    2. Firefox
    3. Internet Explorer
    4. User prompt
* Removed *packages.txt* from installation files. Now using a json array in *utils/config.cfg*

# RInno 0.0.1
* Submitted to CRAN
* Updated LICENSE to conform with GPL-3 standards
* Added DesktopDeployR's Aphache 2.0 copyright notice
* Added Travis-ci, Appveyor, and Codecov to repo
* Added Code of Conduct for contributors

# RInno 0.0.0.9001
* Added a `NEWS.md` file to track changes to the package.
* Built function to install Inno Setup.
* Added support for Bitbucket and GitHub APIs, so that locally deployed shiny apps automatically update during start up sequence.
* Added support for Inno Setup Script sections (start_iss, directives, setup, files, icons, tasks, run, code, and languages), so you can build custom installation wizards in R.
* Added application config file, icons, and installation readme.txt.
* Added package management file which manages a local R library for your shiny app's package dependencies.
* Added error logging
* Modified .onAttach to include information about package version and maintenance
