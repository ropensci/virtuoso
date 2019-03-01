
#' Query the server status
#'
#' @inheritParams vos_kill
#' @inheritParams vos_start
#' @details Note: Use [vos_log()] to see the full log
#' @return a character string indicating the state of the server:
#'  - "not detected" if no process can be found
#'  - "dead" process exists but reports that server is not alive.  Server may fail
#'   to come online due to errors in configuration file. see [vos_configure()]
#'  - "running" Server is up and accepting queries.
#'  - "sleeping" Server is up and accepting queries.
#'
#' @importFrom ps ps_status
#' @export
#' @examples
#' vos_status()
#'
vos_status <- function(p = NA, wait = 10) {
  p <- vos_process(p)
  if (!inherits(p, "ps_handle")) {
    message("virtuoso isn't running.")
    return(invisible(NULL))
  }

  status <- ps::ps_status(p)

  if (!(status %in% c("running", "sleeping"))) {
    return(status)
  }

  log <- vos_log(p, collapse = "\n")
  tries <- 0
  up <- grepl("Server online at", log)
  while (!up && (tries < wait)) {
    Sys.sleep(1)
    log <- vos_log(p, collapse = "\n")
    up <- grepl("Server online at", log)
    tries <- tries + 1
  }

  log <- vos_log(p)
  message(paste("latest log entry:", log[length(log)]))

  status
}
