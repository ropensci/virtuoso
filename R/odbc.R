

vos_odbcinst <- function(odbcinst = NULL){

  if (is.null(odbcinst))
    odbcinst <- find_odbcinst()

  if (file.exists(odbcinst)) {
    if (any(grepl("\\[Local Virtuoso\\]", readLines(odbcinst))) ) {
      message("Configuration for Virtuoso found")
      return(invisible(TRUE))
    }
  }

  if (is_osx()) {
    write(c("", "[Local Virtuoso]",
            "Driver = /usr/local/Cellar/virtuoso/7.2.5.1/lib/virtodbc.so",
            ""),
          file = odbcinst,
          append = TRUE)

  } else if (is_linux()) {
    ## Cannot modify /etc/odbcinst.ini without root
    write(c("", "[Local Virtuoso]",
            "Driver = virtodbc.so",
            ""),
          file = "~/.odbcinst.ini",
          append = TRUE)

  } else {
    stop("Cannot configure odbc for this operating system.")
  }

  invisible(TRUE)
}

find_driver <- function(){
  switch(which_os(){
    "osx" =   find_driver_osx()
    "linux" = find_driver_linux()
    "virtuoso.so"
  })
}
find_driver_osx <- function()

#' @importFrom utils read.table
find_odbcinst <- function(){
  if (Sys.which("odbcinst") == "")
    return(normalizePath("~/.odbcinst.ini", mustWork = FALSE))

  ## Otherwise we can use `odbcinst -j` to find odbcinst.ini file
  p <- processx::run("odbcinst", "-j")
  trimws(
    read.table(textConnection(p$stdout),
               skip = 1, sep = ":",
               stringsAsFactors = FALSE)[1,2]
  )
}
