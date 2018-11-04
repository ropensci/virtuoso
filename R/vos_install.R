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
