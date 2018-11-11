#' Return a handle to an existing Virtuoso Process
#'
#' @inheritParams vos_kill
#' @export
vos_process <- function(p = NA){
  if (!inherits(p, "process")) {
    p <- mget("virtuoso_process",
              envir = virtuoso_cache,
              ifnotfound = NA)[[1]]
  }
  if (!inherits(p, "process")) {
    stop(paste("No virtouso process found.",
               "Try starting one with vos_start()"
    ),
    call. = FALSE
    )
  }
  p
}
