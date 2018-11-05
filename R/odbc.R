
# Rename as vos_odbc_driver ?
vos_odbcinst <- function(odbcinst = NULL){

  if (is.null(odbcinst))
    odbcinst <- find_odbcinst()

  if (file.exists(odbcinst)) {
    if (any(grepl("\\[Local Virtuoso\\]", readLines(odbcinst))) ) {
      message("Configuration for Virtuoso found")
      return(invisible(odbcinst))
    }
  }
  #if (!file.access(odbcinst, mode = 2))# test write access
  odbcinst <- "~/.odbcinst.ini"

  write(c("",
          "[Local Virtuoso]",
          paste("Driver =", find_driver()),
          ""),
          file = odbcinst,
          append = TRUE)

  invisible(odbcinst)
}

find_driver <- function(){
  lookup <- c(
    "/usr/lib/virtodbc.so",
    "/usr/local/lib/virtodbc.so", # Mac Homebrew link
    "/usr/lib/odbc/virtodbc.so",  # Typical Ubuntu virutoso-opensource loc
    "/usr/lib/x86_64-linux-gnu/odbc/virtodbc.so",
    "/usr/local/Cellar/virtuoso/7.2.5.1/lib/virtodbc.so")
  i <- vapply(lookup, file.exists, logical(1L))
  if (!any(i))
    warning("could not automatically locate virtodbc.so driver library")

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
