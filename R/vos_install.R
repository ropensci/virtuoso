#' Helper method for installing Virtuoso Server on Mac OSX
#'
#' @export
#' @importFrom processx run process
vos_install <- function(){
  if (Sys.which('virtuoso-t') != '') {

    vos_configure_odbc()
    return(message(paste("virtuoso already installed.\n")))

  }
  if (!is_osx())
    stop(paste("helper function only supports Mac OSX at this time.",
               "see documentation for details."))

  install_brew()
  processx::run("brew", c("install", "virtuoso"))

  vos_configure_odbc()

}


install_brew <- function() {
  if (Sys.which('brew') == '') {
    processx::run(
      '/usr/bin/ruby',
      '-e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    )
  }
}


vos_configure_odbc <- function(odbcinst = NULL){

  if (is.null(odbcinst))
    odbcinst <- find_odbcinst()

  if (file.exists(odbcinst)) {
    if (any(grepl("\\[Local Virtuoso\\]", readLines(odbcinst))) ) {
      message("Configuration for Virtuoso found")
      return(invisible(TRUE))
    }
  }

  if (is_osx()) {
    write(c("", "[Local Virtuoso]",
            "Driver = /usr/local/Cellar/virtuoso/7.2.5.1/lib/virtodbc.so",
            ""),
          file = odbcinst,
          append = TRUE)

  } else if (is_linux()) {
    ## Cannot modify /etc/odbcinst.ini without root
    write(c("", "[Local Virtuoso]",
            "Driver = /usr/lib/x86_64-linux-gnu/odbc/virtodbc_r.so",
            ""),
          file = "~/.odbcinst.ini",
          append = TRUE)

  } else {
    stop("Can not configure odbc for this operating system.")
  }

  invisible(TRUE)
}

#' @importFrom utils read.table
find_odbcinst <- function(){
  if (Sys.which("odbcinst") == "")
    return(normalizePath("~/.odbcinst.ini", mustWork = FALSE))

  ## Otherwise we can use `odbcinst -j` to find odbcinst.ini file
  p <- processx::run("odbcinst", "-j")
  trimws(
    read.table(textConnection(p$stdout),
               skip = 1, sep = ":",
               stringsAsFactors = FALSE)[1,2]
  )
}
