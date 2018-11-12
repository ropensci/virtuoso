#' Helper method for installing Virtuoso Server on Mac OSX
#'
#' @export
#' @importFrom processx run process
vos_install <- function(){

  ## Windows installation does not persist path currently
  if(is_windows()) vos_set_path_windows()

  # Check if already installed
  if (Sys.which('virtuoso-t') != '') {
    vos_odbcinst(verbose = FALSE)
    return(message(paste("virtuoso already installed.\n")))
  }

  ## Call the appropriate installer
  switch (which_os(),
    "osx" = vos_install_osx(),
    "linux" = vos_install_linux(),
    "windows" = vos_install_windows()
  )


  ## Configure ODBC
  vos_odbcinst()

}

#' @importFrom curl curl_download
vos_install_windows <- function(interactive = interactive()){
  installer <- normalizePath(file.path(
    tempdir(),
    "Virtuoso_OpenSource_Server_7.20.x64.exe"),
    mustWork = FALSE)
  message("downloading...")
  curl::curl_download("https://sourceforge.net/projects/virtuoso/files/virtuoso/7.2.5/Virtuoso_OpenSource_Server_7.20.x64.exe",
                     installer)

  if(interactive){
    message("When asked to create DB and start it, uncheck this option.")
    processx::run(installer)
  } else {
    message("Attempting unsupervised installation of Virtuoso Open Source")
    processx::run(installer,
                  c("/SP-", "/VERYSILENT", "/SUPPRESSMSGBOXES", '/TASKS=""'))
    ## Use installer.exe "/?" to see list of options in cmd

  }
}


vos_set_path_windows <- function(vos_home = virtuoso_home_windows()){
  ## Update path
  bin_dir <- normalizePath(file.path(virtuoso_home_windows(), "bin"), mustWork = FALSE)
  lib_dir <- normalizePath(file.path(virtuoso_home_windows(), "lib"), mustWork = FALSE)
  path <- Sys.getenv("PATH")
  if(!grepl("Virtuoso", path))
    Sys.setenv("PATH" = paste(path, bin_dir, lib_dir, sep=";"))
}


vos_uninstall_windows <- function(vos_home = virtuoso_home_windows()){
  run(file.path(vos_home, "unins000.exe"))
}




vos_install_linux <- function(){
  stop(paste(
    "Package does not support direct install of virtuoso",
    "from R on Linux systems. Please install virtuoso-opensource",
    "for your distribution. e.g. on Debian/Ubuntu systems, run",
    "sudo apt-get -y install virtuoso-opensource"))
}






osx_installer <- "https://sourceforge.net/projects/virtuoso/files/virtuoso/7.2.5/virtuoso-opensource-7.2.5-macosx-app.dmg"

vos_install_osx <- function(  has_unixodbc = FALSE){
  install_brew()

  ## Avoid possible brew install  error:

  ## Error: Cannot install virtuoso because conflicting formulae are installed.
  ## unixodbc: because Both install `isql` binaries.
  ## Please `brew unlink unixodbc` before continuing.
  ## Unlinking removes a formula's symlinks from /usr/local. You can
  ## link the formula again after the install finishes. You can --force this
  ## install, but the build may fail or cause obscure side-effects in the
  ## resulting software.
  if (has_unixodbc | file.exists("/usr/local/bin/isql")){
    has_unixodbc <- TRUE
    processx::run("brew", c("unlink", "unixodbc"))
    #file.rename("/usr/local/bin/isql", "/usr/local/bin/isql-unixodbc")
  }

  processx::run("brew", c("install", "virtuoso"))

  if(has_unixodbc)
    processx::run("brew", c("link", "unixodbc"))

}


install_brew <- function() {
  if (Sys.which('brew') == '') {
    processx::run(
      '/usr/bin/ruby',
      paste('-e "$(curl -fsSL',
      'https://raw.githubusercontent.com/Homebrew/install/master/install)"')
    )
  }
}
