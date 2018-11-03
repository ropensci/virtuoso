
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
  V$Parameters$NumberOfBuffers <- 85000 * gigs_ram
  V$Parameters$MaxDirtyBuffers <- 65000 * gigs_ram

  ## By default on Linux example config, these files are below $HOME and need
  ## root access.  Pointing them at user_log_dir instead.
  V$Database$DatabaseFile <- file.path(db_dir, basename(V$Database$DatabaseFile))
  V$Database$ErrorLogFile <- file.path(db_dir, basename(V$Database$ErrorLogFile))
  V$Database$LockFile <- file.path(db_dir, basename(V$Database$LockFile))
  V$Database$TransactionFile <- file.path(db_dir, basename(V$Database$TransactionFile))
  V$Database$xa_persistent_file <- file.path(db_dir, basename(V$Database$xa_persistent_file))
  V$TempDatabase$DatabaseFile <- file.path(db_dir, basename(V$TempDatabase$DatabaseFile))
  V$TempDatabase$TransactionFile <- file.path(db_dir, basename(V$TempDatabase$TransactionFile))


  output <- file.path(db_dir, "virtuoso.ini")
  ini::write.ini(V, output)
  output
}


## FIXME ick don't hardwire these
find_virtuoso_ini <- function(){
  switch(which_os(),
         osx = "/usr/local/Cellar/virtuoso/7.2.5.1/var/lib/virtuoso/db/virtuoso.ini",
         linux = "/etc/virtuoso-opensource-6.1/virtuoso.ini",
  )
}

