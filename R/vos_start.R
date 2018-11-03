virtuoso_cache <- new.env()

#' Start a Virtuoso Server
#'
#' @param ini path to a virtuoso.ini configuration file. If not
#' provided, function will attempt to determine the location of the
#' default configuration file.
#' @export
vos_start <- function(ini = NULL){

  p <- mget("virtuoso_process",
             envir = virtuoso_cache,
             ifnotfound = NA)[[1]]
  if (inherits(p, "process")) {
    message(paste("Found existing process:",
                  p$format()))
    return(p)
  }


  if (is.null(ini)) {
    ini <- vos_configure()
  }
  err <- tempfile("vos_start", fileext = ".log")
  p <- processx::process$new("virtuoso-t", c("-f", "-c", ini),
                             stderr = err, stdout = "|",
                             cleanup = TRUE)

  ## Cache the process so we can control it later.
  assign("virtuoso_process", p, envir = virtuoso_cache)

  message(p$format())
  vos_status(p)
  invisible(p)
}

#' Stop (kill) the Virtuoso server
#'
#' Kill ends the process started by [`vos_start()`]
#' @param p a process object, returned by
#'  [`vos_process()`] or  [`vos_start()`]
#' @export
vos_kill <- function(p = NA){
 p <- vos_process(p)
 p$kill()
}

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

#' Query the server status
#'
#' @inheritParams vos_kill
#' @export
vos_status <- function(p = NA){

  p <- vos_process(p)

  if (!p$is_alive()) {
    warning(paste("Server failed to start\n"))
    message(cat(readLines(p$get_error_file()), sep = "\n"))
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

  "online"
}

