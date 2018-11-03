
is_osx <- function() unname(Sys.info()['sysname'] == 'Darwin')

is_linux <- function() unname(Sys.info()['sysname'] == 'Linux')

is_windows <- function() .Platform$OS.type == 'windows'

which_os <- function(){
  if (is_osx()) return("osx")
  if (is_linux()) return("linux")
  if (is_windows()) return("windows")
  warning("OS could not be determined")
  NULL
}
