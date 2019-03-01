
#' Query the server logs
#'
#' @param collapse an optional character string to separate the
#' lines in a single character string.
#' @param just_errors logical, default [FALSE]. Set to [TRUE] to return
#' just the lines that contain the term "error", which can be useful
#' in debugging or validating bulk imports.
#' @inheritParams vos_kill
#' @export
#' @return Virtuoso logs as a character vector.
#' @seealso [vos_start()]
#' @examples
#' vos_log()
#'
vos_log <- function(p = NA, collapse = NULL, just_errors = FALSE) {
  p <- vos_process(p)
  if (!inherits(p, "ps_handle")) return("")
  err_file <- file.path(vos_logdir(), "virtuoso.log")
  if(!file.exists(err_file)) return("")
  log <- readLines(err_file)

  if (just_errors) {
    return(log[grepl("error", log)])
  }

  paste(log, collapse = collapse)
}
