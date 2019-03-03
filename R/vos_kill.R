#' Stop (kill) the Virtuoso server
#'
#' Kill ends the process started by [`vos_start()`]
#' @param p a process object, returned by
#'  [`vos_process()`] or  [`vos_start()`].
#'  (will be restored from cache if not provided)
#' @details vos_kill simply shuts down the local Virtuoso server,
#' it does not remove any data stored in the database system.
#' [vos_kill()] terminates the process, removing the
#' process id from the process table.
#' @export
#' @seealso [vos_start()]
#' @aliases vos_kill
#' @importFrom ps ps_kill
#' @examples
#' \donttest{
#' if(has_virtuoso()){
#'
#'   vos_start()
#'   vos_kill()
#'
#'   }
#' }
vos_kill <- function(p = NA) {
  status <- vos_status(p)
  if (is.null(status)) {
    message("No active virtuoso process detected.")
    return(NULL)
  }
  p <- vos_process(p)
  ps::ps_kill(p)
}
