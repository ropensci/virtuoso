#' set Virtuoso paths
#'
#' Set the location of Virtuoso database, configure files,
#' cache, and logs to your preferred location.  Set home
#' to the location of your Virtuoso installation.
#' @param db_dir Location of data in the Virtuoso (tables, triplestore)
#' @param config_dir Location of configuration files for Virtuoso
#' @param cache_dir Location of cache for bulk importing
#' @param log_dir Location of Virutoso Server logs
#' @param home Location of the Virtuoso installation
#' @return A logical vector, with elements being true
#' if setting the corresponding variable succeeded
#' (invisibly).
#'
#' @export
#' @examples
#' if(has_virtuoso())
#'   vos_set_paths()
#'
vos_set_paths <- function(db_dir = vos_db(),
                         config_dir = vos_config(),
                         cache_dir = vos_cache(),
                         log_dir = vos_logdir(),
                         home = virtuoso_home()
){
  if(is_solaris()){
    warning("Virtuoso not available for Solaris", call. = FALSE)
    return("")
  }
  Sys.setenv(VIRTUOSO_DB = db_dir, VIRTUOSO_CONFIG = config_dir,
          VIRTUOSO_CACHE = cache_dir, VIRTUOSO_LOG = log_dir,
          VIRTUOSO_HOME = home)
}

vos_test_paths <- function(){
  x <- tempdir()
  db <- file.path(x, "vos", "db")
  config <- file.path(x, "vos", "config")
  cache <- file.path(x, "vos", "cache")
  log <- file.path(x, "vos", "log")

  dir.create(db, FALSE, TRUE)
  dir.create(config, FALSE, TRUE)
  dir.create(cache, FALSE, TRUE)
  dir.create(log, FALSE, TRUE)

  vos_set_paths(db, config, cache, log)

}

# unset all virtuoso paths
vos_unset_paths <- function(){
  Sys.unsetenv(c("VIRTUOSO_DB", "VIRTUOSO_CONFIG",
               "VIRTUOSO_CACHE", "VIRTUOSO_LOG",
               "VIRTUOSO_HOME"))
}




#' @importFrom rappdirs app_dir
virtuoso_app <- rappdirs::app_dir("Virtuoso")

## database and virtuoso.ini location
vos_db <- function(db_dir =
                     Sys.getenv(
                       "VIRTUOSO_DB",
                       virtuoso_app$data()
                     )) {
  dir.create(db_dir, FALSE, TRUE)
  db_dir
}


## odbc config
vos_config <- function(config_dir =
                         Sys.getenv(
                           "VIRTUOSO_CONFIG",
                           virtuoso_app$config()
                         )) {
  dir.create(config_dir, FALSE, TRUE)
  config_dir
}

## for bulk importer
vos_cache <- function(cache_dir =
                        Sys.getenv(
                          "VIRTUOSO_CACHE",
                          virtuoso_app$cache()
                        )) {
  dir.create(cache_dir, FALSE, TRUE)
  cache_dir
}

# virtuoso processx log (all though virtuoso also logs to vos_db...)
# not to be confused with vos_log() user function to read the logs.
vos_logdir <- function(log_dir =
                         Sys.getenv(
                           "VIRTUOSO_LOG",
                           virtuoso_app$log()
                         )) {
  dir.create(log_dir, FALSE, TRUE)
  log_dir
}



#' @importFrom fs path_norm
odbcinst_path <- function() {
  fs::path_norm(file.path(vos_config(), "odbcinst.ini"))
}

## The system home location
virtuoso_home <- function() {
  switch(which_os(),
    osx = virtuoso_home_osx(),
    windows = virtuoso_home_windows(),
    linux = "/etc/virtuoso-opensource-6.1/virtuoso.ini",
    NULL
  )
}

brew_home <- function() {
  if (!has_homebrew()) return("")
  cmd <- processx::run("brew", c("--prefix", "virtuoso"))
  cmd$stdout
}

virtuoso_home_osx <- function(app = FALSE, use_brew = FALSE) {
  brewhome <- brew_home()
  if (file.exists(brewhome) || use_brew) {
    system_home <- brewhome
  } else {
    system_home <-
      paste0(
        "/Applications/Virtuoso Open Source Edition v7.2.app/",
        "Contents/virtuoso-opensource"
      )
  }
  home <- Sys.getenv("VIRTUOSO_HOME", system_home)


  if (app) return(normalizePath(file.path(home, "..", ".."), mustWork = FALSE))
  home
}

virtuoso_home_windows <- function() {
  system_home <- "C:/Program\ Files/OpenLink\ Software/Virtuoso OpenSource 7.2"
  Sys.getenv("VIRTUOSO_HOME", system_home)
}
