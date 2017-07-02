#' @title Downloads and runs a .exe installer file for some software from a URL
#' @description Gets a character with a link to an installer file, downloads it, runs it, and then erases it.
#' @details
#' This function is used by many functions in the installr package.
#' The .exe file is downloaded into a temporary directory, where it is erased after installation has started (by default - though this can be changed)
#' @param exe_URL A character with a link to an installer file (with the .exe file extension)
#' @param keep_install_file If TRUE - the installer file will not be erased after it is downloaded and run.
#' @param wait should the R interpreter wait for the command to finish? The default is to NOT wait.
#' @param download_dir A character of the directory into which to download the file. (default is \link{tempdir}())
#' @param message boolean. Should a message on the file be printed or not (default is TRUE)
#' @param installer_option A character of the command line arguments
#' @param download_fun a function to use for downloading. Default is \link{download.file}. We can also use
#' \link[curl]{curl_download} (but it doesn't give as good of an output while downloading the file).
#' @param ... parameters passed to 'shell'
#' @return invisible(TRUE/FALSE) - was the installation successful or not. (this is based on the output of shell of running the command being either 0 or 1/2.  0 means the file was successfully installed, while 1 or 2 means there was a failure in running the installer.)
#' @seealso \link{shell}
#' @export
#' @author GERGELY DAROCZI, Tal Galili
#' @examples
#' \dontrun{
#' install.URL("adfadf") # shows the error produced when the URL is not valid.
#' }

install_URL <- function(exe_URL, keep_install_file = FALSE, wait = TRUE, download_dir = tempdir(), message = TRUE, installer_option = NULL, download_fun = download.file, ...) {
  # source: http://stackoverflow.com/questions/15071957/is-it-possible-to-install-pandoc-on-windows-using-an-r-command
  # input: a url of an .exe file to install
  # output: it runs the .exe file (for installing something)

  havingIP <- function() {
    if (.Platform$OS.type == "windows") {
      ipmessage <- system("ipconfig", intern = TRUE)
    } else {
      ipmessage <- system("ifconfig", intern = TRUE)
    }
    validIP <- "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)[.]){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
    any(grep(validIP, ipmessage))
  }


  if(!havingIP()) warning("You do not seem to be connected to the internet. Hence - you will likely not be able to download software.")


  exe_filename <- file.path(download_dir, basename(exe_URL))   # the name of the zip file MUST be as it was downloaded...
  # tryCatch(curl::curl_download(exe_URL, destfile=exe_filename, quiet = FALSE, mode = 'wb'),
  tryCatch(download_fun(exe_URL, destfile=exe_filename, quiet = FALSE, mode = 'wb'),
           error = function(e) {
             cat("\nExplanation of the error: You didn't enter a valid .EXE URL. \nThis is likely to have happened because there was a change in the URL of the installer file in the download page of the software (making our function unable to know what to download). If you think this is the problem, please mail the author jon.mark.hill@gmail.com\n")
             return(invisible(FALSE))
           })

  # check if we downloaded the file.
  if(file.exists(exe_filename)) {
    if(message) cat("\nThe file was downloaded successfully into:\n", exe_filename, "\n")
  } else {
    if(message) cat("\nWe failed to download the file into:\n", exe_filename, "\n(i.e.: the installation failed)\n")
    return(invisible(FALSE))
  }

  if(!keep_install_file & !wait) {
    wait <- TRUE
    if(message) cat("wait was set to TRUE since you wanted to installation file removed. In order to be able to run the installer AND remove the file - we must first wait for the installer to finish running before removing the file.")
  }

  if(message) cat("\nRunning the installer now...\n")


  if(!is.null(installer_option)){
    install_cmd <- paste(exe_filename, installer_option)
  } else{
    install_cmd <- exe_filename
  }

  is.windows <- function(...) unname(Sys.info()["sysname"] == "Windows")

  if(is.windows()) {
    shell_output <- shell(install_cmd, wait = wait,...) # system(exe_filename) # I suspect shell works better than system
  } else {
    shell_output <- system(install_cmd, wait = wait,...) # system(exe_filename) # I suspect shell works better than system
  }
  if(!keep_install_file) {
    if(message) cat("\nInstallation status: ", shell_output == 0 ,". Removing the file:\n", exe_filename, "\n (In the future, you may keep the file by setting keep_install_file=TRUE) \n")
    unlink(exe_filename, force = TRUE) # on.exit(unlink(exe_filename)) # on.exit doesn't work in case of problems in the running of the file
  }
  # unlink can take some time until done, for some reason.
  #    file.remove(exe_filename)
  #    file.info(exe_filename)
  #    file.access(exe_filename, mode = 0)
  #    file.access(exe_filename, mode = 1)
  #    file.access(exe_filename, mode = 2)
  #    file.access(exe_filename, mode = 3)
  return(invisible(shell_output == 0))
  # error code 1/2 means that we couldn't finish running the file
  # # 0 means - the file was successfully installed.
}
