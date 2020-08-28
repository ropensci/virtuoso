## GLOBAL DEFAULT VARS

#' Configure Virtuoso Server ini file
#'
#' Virtuoso Server configuration is determined by a virtuoso.ini file when
#' server starts. This file includes both system-specific information from
#' your install (location of server files, addons, etc) and user-configurable
#' parameters. This helper function provides a way to create and modify an
#' appropriate `virtuoso.ini` file.
#'
#' @param dirs_allowed Paths (relative or absolute) to directories from which
#' Virtuoso should have read and write access (e.g. for bulk uploading). Should
#' be specified as a single comma-separated string.
#' @param gigs_ram Indicate approximately the maximum GB of memory Virtuoso can
#' have access to.  (Used to set NumberOfBuffers & MaxDirtyBuffers in config.)
#' @param template Location of an existing virtuoso.ini file which will be used
#' as a template. By default, `vos_configure()` will attempt to locate the
#' appropriate template for your system.
#' @param db_dir location where `virtuoso.ini` file should be written.  Other
#' Virtuoso database log files will also be written here.
#' @return Writes the requested `virtuoso.ini` file to the db_dir specified
#' and returns the path to this file.
#' @importFrom ini read.ini write.ini
#' @references <http://docs.openlinksw.com/virtuoso/dbadm/>
#' @export
#' @examples
#' \donttest{
#' # can take > 5s to test
#' ## configure with typical defaults:
#' vos_configure()
#' ## Increase or decrease RAM available to virtuoso:
#' vos_configure(gigs_ram = 1)
#' }
vos_configure <- function(dirs_allowed = getwd(),
                          gigs_ram = 2,
                          template = find_virtuoso_ini(),
                          db_dir = vos_db()) {

  if(!file.exists(template)){
    warning("Exiting, virtuoso template not found... is virtuoso installed?")
    return(invisible(NULL))
  }
  dir.create(db_dir, FALSE)

  DirsAllowed <- paste(unique(
    c(
      dirs_allowed, # user-supplied
      ".", # required (refers to ini file, e.g. db_dir())
      vos_cache() # app's cache dir
    )
  ),
  sep = "", collapse = ","
  )

  ## Escape spaces in directory names
  gsub(" ", "\\ ", DirsAllowed)
  ## Consider normalizePaths with winslash="/"

  V <- ini::read.ini(template)
  V$Parameters$DirsAllowed <- DirsAllowed
  V$Parameters$NumberOfBuffers <- 85000 * gigs_ram
  V$Parameters$MaxDirtyBuffers <- 65000 * gigs_ram

  ## By default on Linux example config, these files are below $HOME and need
  ## root access.  Pointing them at user_log_dir instead.
  V$Database$DatabaseFile <-
    file.path(db_dir, basename(V$Database$DatabaseFile))
  V$Database$ErrorLogFile <-
    file.path(db_dir, basename(V$Database$ErrorLogFile))
  V$Database$LockFile <-
    file.path(db_dir, basename(V$Database$LockFile))
  V$Database$TransactionFile <-
    file.path(db_dir, basename(V$Database$TransactionFile))
  V$Database$xa_persistent_file <-
    file.path(db_dir, basename(V$Database$xa_persistent_file))
  V$TempDatabase$DatabaseFile <-
    file.path(db_dir, basename(V$TempDatabase$DatabaseFile))
  V$TempDatabase$TransactionFile <-
    file.path(db_dir, basename(V$TempDatabase$TransactionFile))

  ## Fix relative paths to absolute ones
  if (is_windows()) {
    base <- dirname(template)
    V$Plugins$LoadPath <-
      normalizePath(file.path(base, V$Plugins$LoadPath))
    V$HTTPServer$ServerRoot <-
      normalizePath(file.path(base, V$HTTPServer$ServerRoot))
    V$Parameters$VADInstallDir <-
      normalizePath(file.path(base, V$Parameters$VADInstallDir))
  }

  output <- file.path(db_dir, "virtuoso.ini")
  dir.create(db_dir, FALSE, recursive = TRUE)
  ini::write.ini(V, output)
  output
}

find_virtuoso_ini <- function() {
  switch(which_os(),
    osx = find_virtuoso_ini_osx(),
    windows = find_virtuoso_ini_windows(),
    linux = find_virtuoso_ini_linux(),
    NULL
  )
}

## ick -- hardwire Linux path
find_virtuoso_ini_linux <- function() {
  "/etc/virtuoso-opensource-6.1/virtuoso.ini"
}

## Note: normalizePath fails to simplify /my/path/to/../..
find_virtuoso_ini_windows <- function() {
  normalizePath(file.path(virtuoso_home_windows(), "database", "virtuoso.ini"))
}

find_virtuoso_ini_osx <- function() {
  path_lookup(c(
    file.path(virtuoso_home_osx(), "db", "virtuoso.ini"),
    file.path(virtuoso_home_osx(), "database", "virtuoso.ini"),
    paste0(gsub("\\n$", "", brew_home()), "/var/lib/virtuoso/db/virtuoso.ini")
  ))
}
