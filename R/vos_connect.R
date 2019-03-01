
#' Connect to a Virtuoso Server over ODBC
#'
#' @param driver Name of the Driver line in the ODBC configuration
#' @param uid User id. Defaults to "dba"
#' @param pwd Password. Defaults to "dba"
#' @param host IP address of the Virtuoso Server
#' @param port Port used by Virtuoso. Defaults to
#'  the Virtuoso standard port, 1111
#' @inheritParams vos_odbcinst
#' @details Default parameters are appropriate for the automatic installer
#' provided by the package and for the default settings typically used by
#' local Virtuoso installers.  Adjust these only if you are connecting to a
#' remote virtuoso server that is not controlled from the R package.
#'
#' @export
#' @importFrom DBI dbConnect
#' @importFrom odbc odbc
#' @return a DBI connection to the Virtuoso database.  This can
#' be passed to additional virtuoso functions such as [vos_import()]
#' or [vos_query()], and can also be used as a standard DBI or dplyr
#' database backend.
#' @seealso [vos_install()], [vos_start()]
#' @examples
#' vos_status()
#' \donttest{
#' if(has_virtuoso()){
#' ## start up
#' vos_start()
#' con <- vos_connect()
#' }
#' }
vos_connect <- function(driver = NULL,
                        uid = "dba",
                        pwd = "dba",
                        host = "localhost",
                        port = "1111",
                        system_odbcinst = find_odbcinst(),
                        local_odbcinst = odbcinst_path()) {
  if (is.null(driver)) {
    driver <- switch(which_os(),
      "linux" = "Local Virtuoso",
      "osx" = "Local Virtuoso",
      "windows" = "Virtuoso (Open Source)"
    )
  }

  sysini <- dirname(virtuoso::vos_odbcinst(system_odbcinst, local_odbcinst))
  Sys.setenv(ODBCSYSINI = sysini)

  DBI::dbConnect(odbc::odbc(),
    driver = driver,
    uid = uid,
    pwd = pwd,
    host = host,
    port = port
  )
}
