#' Helper method for installing Virtuoso Server on Mac OSX
#' @param use_brew Should we use homebrew to install? (Mac OSX only)
#' @param prompt Should we prompt user for interactive installation?
#' @export
#' @importFrom processx run process
vos_install <- function(use_brew = FALSE, prompt = is_interactive()){

  if(has_virtuoso())
    return(message("Virtuoso installation found."))

  ## Windows & DMG installers do not persist path
  ## Need path set so we can check if virtuoso is already installed
  vos_set_path()

  # Install Virtuoso if not already installed
  if (!has_virtuoso()) {
    switch (which_os(),
      "osx" = vos_install_osx(use_brew = use_brew, prompt = prompt),
      "linux" = vos_install_linux(),
      "windows" = vos_install_windows(prompt = prompt),
      NULL
    )
  }

  ## Configure ODBC, even if Virtuoso installation already detected
  vos_odbcinst()

}

has_virtuoso <- function(){
  unname(Sys.which('virtuoso-t') != '')
}

vos_set_path <- function(vos_home = NULL){
  ## Virtuoso already detected in PATH
  if (has_virtuoso()){
    return(NULL)
  }

  if (is.null(vos_home)){
    vos_home <- switch (which_os(),
                       "linux" = return(NULL),
                       "osx" = virtuoso_home_osx(),
                       "windows" = virtuoso_home_windows()
                       )
  }
  sep <- switch (which_os(),
                "linux" = ":",
                "osx" = ":",
                "windows" = ";"
                )

  bin_dir <- file.path(vos_home, "bin")

  ## If Virtuoso has not yet been installed, don't modify path yet.
  if(!file.exists(bin_dir)) return(NULL)

  bin_dir <- normalizePath(bin_dir)
  path <- Sys.getenv("PATH")
  Sys.setenv("PATH" = paste(path, bin_dir, sep = sep))
}



