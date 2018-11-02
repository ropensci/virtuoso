#' @export
#' @importFrom processx run process
vos_install <- function(){
  if (Sys.which('virtuoso-t') != '')
    return(message(paste("virtuoso already installed.\n")))

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

#' @export
vos_configure_odbc <- function(odbcinst = "~/.odbcinst.ini"){

  if (file.exists(odbcinst)) {
    if (any(grepl("\\[Local Virtuoso\\]", readLines(odbcinst))) ) {
      message("Configuration for Local Virtuoso found")
      return(invisible(TRUE))
    }
  }
  ## Look for an entry first!
  write(c("", "[Local Virtuoso]",
          "Driver = /usr/local/Cellar/virtuoso/7.2.4.2/lib/virtodbc.so",
          ""),
        file = odbcinst,
        append = TRUE)

  invisible(TRUE)
}

#' @export
vos_start <- function(ini = system.file("virtuoso",
                                        "virtuoso.ini",
                                        package = "virtuoso")){

  ## FIXME: check if virtuoso is already running first?

  file.copy(ini, basename(ini))
  p <- processx::process$new("virtuoso-t", "-f")
  invisible(p)
}


#' @export
#' @importFrom DBI dbConnect
#' @importFrom odbc odbc
vos_connect <- function(driver = "Local Virtuoso",
                             uid = "dba",
                             pwd = "dba",
                             host = "localhost",
                             port = "1111"){
  DBI::dbConnect(odbc::odbc(),
                 driver = driver,
                 uid = uid,
                 pwd = pwd,
                 host = host,
                 port = port)
}

is_osx <- function() unname(Sys.info()['sysname'] == 'Darwin')


#library(rdflib)
#triplestore  <- rdf(storage = "virtuoso", user = "dba", password = "dba", host="localhost:1111")
