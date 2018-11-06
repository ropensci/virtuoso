
#' Query the server status
#'
#' @inheritParams vos_kill
#' @inheritParams vos_start
#' @export
vos_status <- function(p = NA, wait = 10){

  p <- vos_process(p)

  if (!p$is_alive()) {
    warning(paste("Server is not alive. Server log: \n\n",
    readLines(p$get_error_file())))
    return("dead")
  }

  if (p$get_status() != "running") # stopped,
    return(p$get_status())

  Sys.sleep(1)
  log <- paste(readLines(p$get_error_file()), collapse = "\n")
  tries <- 0
  up <- grepl("Server online at", log)
  while (!up && tries < wait) {
    Sys.sleep(1)
    log <- paste(readLines(p$get_error_file()), collapse = "\n")
    up <- grepl("Server online at", log)
    tries <- tries + 1
  }
  message(log[length(log)])

  "running"
}

