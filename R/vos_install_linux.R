
vos_install_linux <- function() {
  message(paste(
    "Package does not support direct install of virtuoso",
    "from R on Linux systems. Please install virtuoso-opensource",
    "for your distribution. e.g. on Debian/Ubuntu systems, run",
    "sudo apt-get -y install virtuoso-opensource"
  ))
}
