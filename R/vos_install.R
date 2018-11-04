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


  if (!is_osx())
    stop(paste("helper function only supports Mac OSX at this time.",
               "see documentation for details."))

  install_brew()

  ## Avoid possible brew install  error:

  ## Error: Cannot install virtuoso because conflicting formulae are installed.
  ## unixodbc: because Both install `isql` binaries.
  ## Please `brew unlink unixodbc` before continuing.
  ## Unlinking removes a formula's symlinks from /usr/local. You can
  ## link the formula again after the install finishes. You can --force this
  ## install, but the build may fail or cause obscure side-effects in the
  ## resulting software.
  if (file.exists("/usr/local/bin/isql"))
    file.rename("/usr/local/bin/isql", "/usr/local/bin/isql-unixodbc")

  processx::run("brew", c("install", "virtuoso"))

  vos_odbcinst()

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
