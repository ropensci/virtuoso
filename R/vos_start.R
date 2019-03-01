virtuoso_cache <- new.env()

#' Start a Virtuoso Server
#'
#' This function will attempt to start a virtuoso server
#' instance that can be managed completely from R.  This allows
#' the user to easily start, stop, and access server logs and functions
#' from the R command line.  This server will be automatically shut
#' down when R exits or restarts, or can be explicitly controlled using
#' [vos_kill()], [vos_log()], and [vos_status()].
#'
#' @param ini path to a virtuoso.ini configuration file. If not
#' provided, function will attempt to determine the location of the
#' default configuration file.
#' @param wait number of seconds to wait for server to come online
#' @export
#' @return invisibly returns the [processx::process()] object which can be used
#' to control the external process from R.  It is not necessary for a user
#' to store this return object, as [vos_start()] caches the process object so
#' it can be automatically accessed by other functions without needing to store
#' and pass the return object.
#' @details  It can take some time for the server to come up before it is ready to
#' accept queries.  [vos_start()] will return as soon as the server is active,
#' which typically takes about 10 seconds on tested systems. [vos_start()] monitors
#' the Virtuoso logs every one second for a maximum time of `wait` seconds
#' (default 30 seconds) to see if the server is ready.  If `wait` time is exceeded,
#' [vos_start()] will simply return the current server status.  This does not mean
#' that starting has failed, it may simply need longer before the server is active.
#' Use [vos_status()] to continue to monitor the server status manually.
#'
#' If no `virtuoso.ini` configuration file is provided, [vos_start()] will
#' automatically attempt to configure one.  For more control over this,
#' use [vos_configure()], see examples.
#' @importFrom ps ps_pid
#' @seealso [vos_install()]
#' @examples
#' \donttest{
#'
#' if(has_virtuoso()){
#' vos_start()
#' ## or with custom config:
#' vos_start(vos_configure(gigs_ram = 3))
#'
#' }
#' }
vos_start <- function(ini = NULL, wait = 30) {

  ## Windows & Mac-dmg-based installers do not persist path
  ## Need path set so we can check if virtuoso is already installed
  vos_set_path()

  if (!has_virtuoso()) {
    stop(paste(
      "Virtuoso installation not detected.",
      "Try running: vos_install()"
    ))
  }


  ## Check for cached process
  p <- vos_process()

  if (inherits(p, "ps_handle")) {
    message(paste(
      "Virtuoso is already running with pid:",
      ps::ps_pid(p)
    ))
    return(invisible(p))
  }

  ## Prepare a virtuoso.ini configuration file if one is not provided.
  if (is.null(ini)) {
    ini <- vos_configure()
  }

  ## Here we go time to start the process
  err <- file.path(vos_logdir(), "virtuoso.log")

  px <- processx::process$new("virtuoso-t", c("-f", "-c", ini),
    stderr = err, stdout = "|",
    cleanup = TRUE
  )


  ## Wait for status
  message(px$format())
  message("Server is now starting up, this may take a few seconds...\n")
  Sys.sleep(2)
  vos_status(wait = wait)

  assign("px", px, envir = virtuoso_cache)
  ##
  invisible(vos_process())
}

