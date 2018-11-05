
#' Query the server status
#'
#' @inheritParams vos_kill
#' @export
vos_status <- function(p = NA){

  p <- vos_process(p)

  if (!p$is_alive()) {
    warning(paste("Server is not alive. Server log: \n\n",
    readLines(p$get_error_file())))
    return("dead")
  }

  if (p$get_status() != "running") # stopped,
    return(p$get_status())

  Sys.sleep(1)
  log <- readLines(p$get_error_file())
  tries <- 0
  up <- grepl("Server online at", log[[length(log)]])
  while (!up && tries < 10) {
    Sys.sleep(1)
    log <- readLines(p$get_error_file())
    up <- grepl("Server online at", log[[length(log)]])
    tries <- tries + 1
  }
  message(log[length(log)])

  "running"
}

