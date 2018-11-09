
#' Query the server logs
#'
#' @param collapse an optional character string to separate the
#' lines in a single character string.
#' @param just_errors logical, default FALSE. Set to true to return
#' just the lines that contain the term "error", which can be useful
#' in debugging or validating bulk imports.
#' @inheritParams vos_kill
#' @export
vos_log <- function(p = NA, collapse = NULL, just_errors = FALSE){

  p <- vos_process(p)

  log <- readLines(p$get_error_file())
  if(just_errors){
    return(log[grepl("error", log)])
  }

  paste(log, collapse = collapse)

}

