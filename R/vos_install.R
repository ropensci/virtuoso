#' Helper method for installing Virtuoso Server
#'
#' Installation helper for Mac and Windows machines.  By default,
#' method will download and launch the official `.dmg` or `.exe` installer
#' for your platform, running the standard drag-n-drop installer or
#' interactive dialog.  Setting `ask = FALSE` will allow the installer
#' to run entirely unsupervised, which is suitable for use in scripts.
#' Mac users can alternatively opt to install Virtuoso through HomeBrew
#' by setting `use_brew=TRUE`. Linux users should simply install the
#' `virtuoso-opensource` package (e.g. in debian & ubuntu) using the
#' package manager or by contacting your system administrator.
#'
#' @seealso [vos_start()], [vos_uninstall()]
#' @param use_brew Should we use homebrew to install? (MacOS only)
#' @param ask Should we ask user for interactive installation?
#' @export
#' @importFrom processx run process
#' @examples
#' \dontshow{ if(has_virtuoso()) }
#' vos_install()
#'
vos_install <- function(ask = is_interactive(), use_brew = FALSE) {

  ## Windows & DMG installers do not persist path
  ## Need path set so we can check if virtuoso is already installed
  vos_set_path()

  if (has_virtuoso()) {
    return(message("Virtuoso is already installed."))
  }


  # Install Virtuoso if not already installed
  if (!has_virtuoso()) {
    switch(which_os(),
      "osx" = vos_install_osx(use_brew = use_brew, ask = ask),
      "linux" = vos_install_linux(),
      "windows" = vos_install_windows(ask = ask),
      NULL
    )
  }

  ## Configure ODBC, even if Virtuoso installation already detected
  vos_odbcinst()
}


#' check for Virtuoso
#'
#' test if the system has a virtuoso installation on the path
#' @return logical indicating if virtuoso-t binary was found or now.
#' @examples
#' has_virtuoso()
#' @export
has_virtuoso <- function() {
  vos_set_path()
  file.exists(unname(Sys.which("virtuoso-t")))
}




vos_set_path <- function(vos_home = NULL) {
  if(is_solaris()){
    message("virtuoso R package is not supported on Solaris")
    return(NULL)
  }

    ## Virtuoso already detected in PATH
  if (file.exists(unname(Sys.which("virtuoso-t")))) {
    return(NULL)
  }

  if (is.null(vos_home)) {
    vos_home <- switch(which_os(),
      "linux" = return(NULL),
      "osx" = virtuoso_home_osx(),
      "windows" = virtuoso_home_windows()
    )
  }
  sep <- switch(which_os(),
    "linux" = ":",
    "osx" = ":",
    "windows" = ";",
    ":"
  )

  bin_dir <- file.path(vos_home, "bin")

  ## If Virtuoso has not yet been installed, don't modify path yet.
  if (!file.exists(bin_dir)) return(NULL)

  bin_dir <- normalizePath(bin_dir)
  path <- Sys.getenv("PATH")
  Sys.setenv("PATH" = paste(path, bin_dir, sep = sep))

  invisible(path)
}
