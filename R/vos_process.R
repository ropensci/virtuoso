#' Return a handle to an existing Virtuoso Process
#'
#' Generally a user will not need to access this function directly,
#' though it may be useful for debugging purposes.
#' @inheritParams vos_kill
#' @return returns the [processx::process()] object cached by [vos_start()]
#' to control the external Virtuoso sever process from R.
#' @export
#' @examples \dontrun{
#'
#' vos_start()
#' p <- vos_process()
#' p
#' }
#'
vos_process <- function(p = NA){
  if (!inherits(p, "process")) {
    p <- mget("virtuoso_process",
              envir = virtuoso_cache,
              ifnotfound = NA)[[1]]
  }
  if (!inherits(p, "process")) {
    message(paste("No virtouso process found.",
               "Try starting one with vos_start()"
    ),
    call. = FALSE)
  }
  p
}
