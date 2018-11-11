#' Stop (kill) the Virtuoso server
#'
#' Kill ends the process started by [`vos_start()`]
#' @param p a process object, returned by
#'  [`vos_process()`] or  [`vos_start()`]
#' @export
vos_kill <- function(p = NA){
  p <- vos_process(p)
  p$kill()
  rm("virtuoso_process", envir = virtuoso_cache)
}
