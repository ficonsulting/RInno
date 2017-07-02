# Copy pandoc files to app directory
pandoc_file_copy <- function(app_dir){
  config <- jsonlite::fromJSON(file.path(app_dir, "utils/config.cfg"))
  if(config$flex_file != "none"){

    pandoc_path <- ifelse(Sys.getenv("RSTUDIO_PANDOC") == "", "none", Sys.getenv("RSTUDIO_PANDOC"))

    if(pandoc_path != "none"){
      copy_status <- file.copy(pandoc_path, paste0(app_dir,"/utils/"), recursive = T)
      if(copy_status == T)
      {
        message("Pandoc included into utils for Flexdashboard\n")
      } else {
        stop("The necessary Pandoc files, which is a dependency of Flexdashboards could not be copied into the designated app library folder\n")
      }
    } else(
      stop("The necessary Pandoc files, which is a dependency of Flexdashboards could not found. Please run the `install_pandoc()` function before trying to compile to install the necessary files that are required to run a Flexdashboard shiny app\n")
    )
  }
}
