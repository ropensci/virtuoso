virtuoso_cache <- new.env()

#' Start a Virtuoso Server
#'
#' @param ini path to a virtuoso.ini configuration file. If not
#' provided, function will attempt to determine the location of the
#' default configuration file.
#' @param wait number of seconds to wait for server to come online
#' @export
vos_start <- function(ini = NULL, wait = 10){

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
  message("Server is now starting up, this may take a few seconds...\n")
  vos_status(p, wait = wait)
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
 rm("virtuoso_process", envir = virtuoso_cache)
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
