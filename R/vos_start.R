virtuoso_cache <- new.env()

#' Start a Virtuoso Server
#'
#' @param ini path to a virtuoso.ini configuration file. If not
#' provided, function will attempt to determine the location of the
#' default configuration file.
#' @param wait number of seconds to wait for server to come online
#' @export
vos_start <- function(ini = NULL, wait = 30){

  if(!has_virtuoso())
    stop(paste("Virtuoso installation not detected.  See vos_install()"))


  ## Check for cached process
  p <- mget("virtuoso_process", envir = virtuoso_cache, ifnotfound = NA)[[1]]
  if (inherits(p, "process")) {
    message(paste("Found existing process:", p$format()))
    return(p)
  }

  ## Some installers (windows, dmg) do not set a persistent path.
  vos_set_path()

  ## Prepare a virtuoso.ini configuration file if one is not provided.
  if (is.null(ini)) {
    ini <- vos_configure()
  }

  ## Here we go time to start the process
  err <- tempfile("vos_start", fileext = ".log")
  p <- processx::process$new("virtuoso-t", c("-f", "-c", ini),
                             stderr = err, stdout = "|",
                             cleanup = TRUE)

  ## Cache the process so we can control it later.
  assign("virtuoso_process", p, envir = virtuoso_cache)

  ## Wait for status
  message(p$format())
  message("Server is now starting up, this may take a few seconds...\n")
  Sys.sleep(2)
  vos_status(p, wait = wait)


  ##
  invisible(p)
}


