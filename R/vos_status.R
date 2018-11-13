
#' Query the server status
#'
#' @inheritParams vos_kill
#' @inheritParams vos_start
#' @details Note: Use `[vos_log()]`` to see the full log
#' @export
vos_status <- function(p = NA, wait = 10){

  if(!inherits(p, "process")) if(is.na(p)) p <- vos_process(p)

  if (!p$is_alive()) {
    warning(paste("Server is not alive. Server log: \n\n",
                  vos_log(p)))
    return("dead")
  }

  if (!(p$get_status() %in% c("running", "sleeping"))) # stopped,
    return(p$get_status())

  Sys.sleep(1)
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

  p$get_status()
}
