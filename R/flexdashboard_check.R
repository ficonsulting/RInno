flexdashboard_check <- function(file){
  # Identify and read in yaml
  yaml_index <- grep("---", readLines(file), fixed = T)
  yaml_content <- readLines(file, (yaml_index[2] - 1))[-1]

  # Check if flexdashboard format in rmd
  any(grepl("flexdashboard", yaml_content))
}


