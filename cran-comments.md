## This update
* quick hotfix related to dependency version numbers

## Test environments
* local OS Windows 7 x64, R 3.5.1

## R CMD check results
There were 0 errors, 0 Warnings and 0 NOTES on Windows OS. There are warnings/notes on Mac/Linux
OS due to dependencies that are not available in those environments. RInno is also
not available in those environments, so this should not be an issue.

shiny, rmarkdown and httr are imported by RInno for demos but those packages are
not directly used by RInno.

## Downstream dependencies
RInno does not have any downstream dependencies.
