#' Return a handle to an existing Virtuoso Process
#'
#' Generally a user will not need to access this function directly,
#' though it may be useful for debugging purposes.
#' @inheritParams vos_kill
#' @return returns the [processx::process()] object cached by [vos_start()]
#' to control the external Virtuoso sever process from R.
#' @importFrom ps ps_handle ps
#' @export
#' @examples
#' vos_process()
#'
vos_process <- function(p = NA) {

  ## p already is a handle to the process
  if (inherits(p, "ps_handle")) {
    return(p)
  }

  ## Otherwise, discover the pid
  pid <- virtuoso_pid()

  ## No pid means no running process
  if (length(pid) == 0) return(NA)

  ## Success. return a handle to this pid
  ps::ps_handle(pid)
}


virtuoso_pid <- function(...) {
  x <- ps::ps(...)
  x$pid[grepl("virtuoso-t", x$name)]
}
