
#' Uninstall Virtuoso
#'
#' Automatic uninstaller for Mac OSX and Windows clients.
#' @export
vos_uninstall <- function(){
  if(!has_virtuoso())
    return(warning("Virtuoso installation not found", call. = FALSE))

  ## Call the appropriate installer
  switch (which_os(),
          "osx" = vos_uninstall_osx(),
          "linux" = paste("Cannot automatically uninstall",
                          "on Linux, use system tools."),
          "windows" = vos_uninstall_windows(),
          NULL
  )
}
