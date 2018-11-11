#' Helper method for installing Virtuoso Server on Mac OSX
#'
#' @export
#' @importFrom processx run process
vos_install <- function(){

  # Check if already installed
  if (Sys.which('virtuoso-t') != '') {
    vos_odbcinst()
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

vos_install_windows <- function(){
  ## Update path
  bin_dir <- normalizePath(file.path(virtuoso_home_windows(), "bin"))
  lib_dir <- normalizePath(file.path(virtuoso_home_windows(), "lib"))
  path <- Sys.getenv("PATH")
  if(!grepl("Virtuoso", path))
  Sys.setenv("PATH" = paste(path, bin_dir, lib_dir, sep=";"))
}

vos_install_linux <- function(){
  stop(paste(
    "Package does not support direct install of virtuoso",
    "from R on Linux systems. Please install virtuoso-opensource",
    "for your distribution. e.g. on Debian/Ubuntu systems, run",
    "sudo apt-get -y install virtuoso-opensource"))
}



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
