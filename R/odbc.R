
# Rename as vos_odbc_driver ?
vos_odbcinst <- function(odbcinst = NULL, verbose = TRUE){

  if (is.null(odbcinst))
    odbcinst <- find_odbcinst()

  if (!assert_unset(odbcinst)) return(invisible(odbcinst))

  #if (!file.access(odbcinst, mode = 2))# test write access
  ## Writing our own odbcinst always seems more robust.
  ## including the above test seems to break travis ability to connect

  ## Make sure we have not already set this
  odbcinst <- "~/.odbcinst.ini"
  if (!assert_unset(odbcinst)) return(invisible(odbcinst))

  write(c("",
          "[Local Virtuoso]",
          paste("Driver =", find_odbc_driver()),
          ""),
          file = odbcinst,
          append = TRUE)

  invisible(odbcinst)
}

assert_unset <- function(odbcinst){
  if (file.exists(odbcinst)) {
    if (any(grepl("\\[Local Virtuoso\\]", readLines(odbcinst))) ) {
      #message("Configuration for Virtuoso found")
      return(FALSE)
    }
  }
  TRUE
}


find_odbc_driver <- function(){
  if(is_osx()){
    lookup <- c(
      "/usr/lib/virtodbc.so",
      "/usr/local/lib/virtodbc.so", # Mac Homebrew symlink
      "/usr/lib/odbc/virtodbc.so",  # Typical Ubuntu virutoso-opensource location
      "/usr/lib/x86_64-linux-gnu/odbc/virtodbc.so", # Debian location
      "/usr/local/Cellar/virtuoso/7.2.5.1/lib/virtodbc.so", # Homebrew unlinked location
      file.path(virtuoso_home_osx(), "lib", "virtodbc.so")
    )
  } else if (is_linux()){
    lookup <- c(
      "/usr/lib/virtodbc.so",
      "/usr/local/lib/virtodbc.so",
      "/usr/lib/odbc/virtodbc.so",
      "/usr/lib/x86_64-linux-gnu/odbc/virtodbc.so")
  } else if( is_windows()) {
    lookup <- normalizePath(file.path(
      virtuoso_home_windows(), "bin", "virtodbc.dll"))
  } else {
    stop("OS not recognized or not supported")
  }
  path_lookup(lookup)
}

path_lookup <- function(paths, target_name = basename(paths[[1]])){
  i <- vapply(paths, file.exists, logical(1L))
  if (!any(i))
    warning(paste("could not automatically locate", target_name),
            call. = FALSE)

  names(which(i))[[1]]
}



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
