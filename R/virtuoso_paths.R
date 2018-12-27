
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


#' Destroy all Virtuoso's directories
#'
#' for a clean reset of the system that purges all
#' data files, config files, cache and log files created
#' by virtuoso R package.
#' @param force should permissions be changed (if possible) to allow deletion?
#' @return TRUE if entirely successful in removing all files,
#'  FALSE otherwise (invisibly).
#' @export
vos_destroy_all <- function(force = FALSE){
  s1 <- unlink(vos_db(), recursive = TRUE, force = force)
  s2 <- unlink(vos_cache(), recursive = TRUE, force = force)
  s3 <- unlink(vos_config(), recursive = TRUE, force = force)
  s4 <- unlink(vos_logdir(), recursive = TRUE, force = force)
  invisible(sum(c(s1,s2,s3,s4)) == 0)
}

#' @importFrom fs path_norm
odbcinst_path <- function(){
  fs::path_norm(file.path(vos_config(), "odbcinst.ini"))
}

## The system home location
virtuoso_home <- function(){
  switch(which_os(),
         osx = virtuoso_home_osx(),
         windows = virtuoso_home_windows(),
         linux = "/etc/virtuoso-opensource-6.1/virtuoso.ini",
         NULL
  )
}

brew_home <- function(){
  if(!has_homebrew()) return("")
  cmd <- processx::run("brew", c("--prefix", "virtuoso"))
  cmd$stdout
}

virtuoso_home_osx <- function(app = FALSE, use_brew = FALSE){
  brewhome <- brew_home()
  if(file.exists(brewhome) || use_brew){
    system_home <- brewhome
  } else {
    system_home <-
      paste0("/Applications/Virtuoso Open Source Edition v7.2.app/",
             "Contents/virtuoso-opensource")
  }
  home <- Sys.getenv("VIRTUOSO_HOME", system_home)


  if(app) return(normalizePath(file.path(home, "..", ".."), mustWork = FALSE))
  home
}

virtuoso_home_windows <- function(){
  system_home <- "C:/Program\ Files/OpenLink\ Software/Virtuoso OpenSource 7.20"
  Sys.getenv("VIRTUOSO_HOME", system_home)
}
