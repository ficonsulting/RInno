## This update
* critical bug fix for the CRAN package
* adds OS_system: windows

## Test environments
* local OS Windows 7 x64, R 3.3.3

## R CMD check results
There were no ERRORs

1 WARNING
* "qpdf" being required to create reduced size pdfs.

2 NOTES
* installr must be imported because users of v0.0.1 got a hard error when calling `install_inno()`. Even though it is only one function in the package, it must be called for the rest of the package to work properly.
* It does not like the urls used in readme badges.

## Downstream dependencies
RInno does not have any downstream dependencies.
