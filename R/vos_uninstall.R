
#' Uninstall Virtuoso
#'
#' Automatic uninstaller for Mac OSX and Windows clients.
#' @export
#' @examples
#' \dontrun{
#' vos_uninstall()
#' }
#'
vos_uninstall <- function() {
  vos_set_path()
  if (!has_virtuoso()) {
    return(message("Virtuoso installation not found", call. = FALSE))
  }

  ## Call the appropriate installer
  switch(which_os(),
    "osx" = vos_uninstall_osx(),
    "linux" = paste(
      "Cannot automatically uninstall",
      "on Linux, use system tools."
    ),
    "windows" = vos_uninstall_windows(),
    NULL
  )
}
