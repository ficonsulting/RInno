## This update
* Improves users' control over package dependencies

## Test environments
* local OS Windows 7 x64, R 3.4.3

## R CMD check results
There were no ERRORs and no NOTES on Windows OS. There are warnings/notes on Mac/Linux
OS due to dependencies that are not available in those environments. RInno is also
not available in those environments, so this should not be an issue.

shiny, rmarkdown and httr are imported by RInno for demos but those packages are
not directly used by RInno.

1 WARNING
* "qpdf" being required to create reduced size pdfs.

## Downstream dependencies
RInno does not have any downstream dependencies.
