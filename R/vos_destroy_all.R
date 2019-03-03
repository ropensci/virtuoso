
#' Destroy all Virtuoso's directories
#'
#' Provides a clean reset of the system that purges all
#' data files, config files, cache and log files created
#' by virtuoso R package. This does not uninstall Virtuoso software
#' itself, see [vos_uninstall()] to uninstall.
#'
#' @param force should permissions be changed (if possible) to allow deletion?
#' @return [TRUE] if entirely successful in removing all files,
#'  [FALSE] otherwise (invisibly).
#' @export
#' @examples
#'
#' \dontshow{
#' virtuoso:::vos_test_paths()
#' }
#' vos_destroy_all()
#'
vos_destroy_all <- function(force = FALSE) {
  s1 <- unlink(vos_db(), recursive = TRUE, force = force)
  s2 <- unlink(vos_cache(), recursive = TRUE, force = force)
  s3 <- unlink(vos_config(), recursive = TRUE, force = force)
  s4 <- unlink(vos_logdir(), recursive = TRUE, force = force)
  invisible(sum(c(s1, s2, s3, s4)) == 0)
}

#' Delete Virtuoso Database
#'
#' delete the entire Virtuoso database for a fresh start.
#' @param ask ask before deleting?
#' @param db_dir location of the directory to delete
#' @export
#' @examples
#'
#' \dontshow{
#' virtuoso:::vos_test_paths()
#' }
#' vos_delete_db()
#'
vos_delete_db <- function(ask = is_interactive(),
                          db_dir = vos_db()) {
  continue <- TRUE
  if (ask) {
    continue <- askYesNo("Are you sure?")
  }
  if (continue) {
    unlink(db_dir, recursive = TRUE)
  }
}
