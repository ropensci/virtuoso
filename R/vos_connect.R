
#' Connect to a Virtuoso Server over ODBC
#'
#' @param driver Name of the Driver line in the ODBC configuration
#' @param uid User id. Defaults to "dba"
#' @param pwd Password. Defaults to "dba"
#' @param host IP address of the Virtuoso Server
#' @param port Port used by Virtuoso. Defaults to
#'  the Virtuoso standard port, 1111
#' @inheritParams vos_odbcinst
#'
#' @export
#' @importFrom DBI dbConnect
#' @importFrom odbc odbc
vos_connect <- function(driver = NULL,
                        uid = "dba",
                        pwd = "dba",
                        host = "localhost",
                        port = "1111",
                        system_odbcinst = find_odbcinst(),
                        local_odbcinst = odbcinst_path()){
  if(is.null(driver)){
    driver <- switch(which_os(),
           "linux" = "Local Virtuoso",
           "osx" = "Local Virtuoso",
           "windows" = "Virtuoso (Open Source)")
  }

  sysini <- dirname(virtuoso::vos_odbcinst(system_odbcinst, local_odbcinst))
  Sys.setenv(ODBCSYSINI= sysini)

  DBI::dbConnect(odbc::odbc(),
                 driver = driver,
                 uid = uid,
                 pwd = pwd,
                 host = host,
                 port = port)

}



#library(rdflib)
#triplestore  <- rdf(storage = "virtuoso", user = "dba", password = "dba", host="localhost:1111")
