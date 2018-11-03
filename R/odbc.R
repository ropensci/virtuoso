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

#' @importFrom utils read.table
find_odbcinst <- function(){
  if (Sys.which("odbcinst") == "")
    return(normalizePath("~/.odbcinst.ini"))

  ## Otherwise we can use `odbcinst -j` to find odbcinst.ini file
  p <- processx::run("odbcinst", "-j")
  trimws(
    read.table(textConnection(p$stdout),
               skip = 1, sep = ":",
               stringsAsFactors = FALSE)[1,2]
  )
}


vos_configure_odbc <- function(odbcinst = NULL){

  if (is.null(odbcinst))
    odbcinst <- find_odbcinst()

  if (file.exists(odbcinst)) {
    if (any(grepl("\\[Local Virtuoso\\]", readLines(odbcinst))) ) {
      message("Configuration for Local Virtuoso found")
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

# virtuoso.ini file provides the default configuration
# Crucially, it sets AllowedDirs that we can bulk import from



find_virtuoso_ini <- function(){
  switch(which_os(),
         osx = "/usr/local/Cellar/virtuoso/7.2.5.1/var/lib/virtuoso/db/virtuoso.ini",
         linux = "/etc/virtuoso-opensource-6.1/virtuoso.ini",
         )
}

#' @importFrom ini read.ini write.ini
#' @importFrom rappdirs user_log_dir
vos_configure <- function(ini_file = find_virtuoso_ini(),
                          DirsAllowed = ".",
                          gigs_ram = 2,
                          db_dir = rappdirs::user_log_dir("Virtuoso")){

  ## dbdir cannot have spaces in path(?)
  dir.create(db_dir, FALSE)

  V <- ini::read.ini(ini_file)
  V$Parameters$DirsAllowed <- DirsAllowed
  V$Database$DatabaseFile <- file.path(db_dir, basename(V$Database$DatabaseFile))
  V$Database$ErrorLogFile <- file.path(db_dir, basename(V$Database$ErrorLogFile))
  V$Database$LockFile <- file.path(db_dir, basename(V$Database$LockFile))
  V$Database$TransactionFile <- file.path(db_dir, basename(V$Database$TransactionFile))
  V$Database$xa_persistent_file <- file.path(db_dir, basename(V$Database$xa_persistent_file))

  V$TempDatabase$DatabaseFile <- file.path(db_dir, basename(V$TempDatabase$DatabaseFile))
  V$TempDatabase$TransactionFile <- file.path(db_dir, basename(V$TempDatabase$TransactionFile))

  V$Parameters$NumberOfBuffers <- 85000 * gigs_ram
  V$Parameters$MaxDirtyBuffers <- 65000 * gigs_ram

  output <- file.path(db_dir, "virtuoso.ini")
  ini::write.ini(V, output)
  output
}

#' Start a local Virtuoso Server
#'
#' @param ini path to a virtuoso.ini configuration file. If not
#' provided, function will attempt to determine the location of the
#' default configuration file.
#' @export
vos_start <- function(ini = NULL){

  if (is.null(ini)) {
    ini <- vos_configure()
  }
  p <- processx::process$new("virtuoso-t", c("-f", "-c", ini))
  invisible(p)
}



#' Connect to a Virtuoso Server over ODBC
#'
#' @param driver Name of the Driver line in the ODBC configuration
#' @param uid User id. Defaults to "dba"
#' @param pwd Password. Defaults to "dba"
#' @param host IP address of the Virtuoso Server
#' @param port Port used by Virtuoso. Defaults to
#'  the Virtuoso standard port, 1111
#'
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


## Helper routines
is_osx <- function() unname(Sys.info()['sysname'] == 'Darwin')
is_linux <- function() unname(Sys.info()['sysname'] == 'Linux')
is_windows <- function() .Platform$OS.type == 'windows'
which_os <- function(){
  if (is_osx()) return("osx")
  if (is_linux()) return("linux")
  if (is_windows()) return("windows")
  warning("OS could not be determined")
  NULL
}


#library(rdflib)
#triplestore  <- rdf(storage = "virtuoso", user = "dba", password = "dba", host="localhost:1111")
