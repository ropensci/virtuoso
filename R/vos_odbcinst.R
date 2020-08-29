# Rename? Maybe vos_odbc_configure?


#' Configure the ODBC Driver for Virtuoso
#'
#' ODBC uses an `odbcinst.ini` file to point ODBC at the library required
#' to drive any given database.  This function helps us automatically
#' locate the driver library on different operating systems and configure
#' the odbcinst appropriately for each OS.
#'
#' @param system_odbcinst Path to the system `odbcinst.ini` file. (Does not
#' require write access.) Default will attempt to find the file for your system.
#' @param local_odbcinst Path to the local odbcinst we should use.
#' @return the path to the odbcinst file that is created or modified.
#'
#' @details This function is called automatically by [vos_install()] and thus
#' does not usually need to be called by the user.  Users can also manually
#' configure ODBC as outlined in
#' <https://github.com/r-dbi/odbc#dsn-configuration-files>.
#' This is merely a convenience function automating that process on most
#' systems.
#'
#' @examples
#' \donttest{
#' ## Configures ODBC and returns silently on success.
#' vos_odbcinst()
#'
#' ## see where the inst file is located:
#' inst <- vos_odbcinst()
#' inst
#' }
#' @export
vos_odbcinst <-
  function(system_odbcinst = find_odbcinst(),
             local_odbcinst = odbcinst_path()) {

    ## NOTE: This applies to and is used only by on MacOS / Linux
    Sys.setenv(ODBCSYSINI = dirname(local_odbcinst))

    ## Use local odbcinst if already configured
    if (already_set(local_odbcinst)) {
      return(invisible(local_odbcinst))
    }

    ## Then use system odbcinst if that is configured
    ## NO -- don't trust system odbcinst to be already set
    # if (already_set(system_odbcinst)){
    #  # Sys.setenv(ODBCSYSINI=system_odbcinst)
    #  return(invisible(system_odbcinst))
    # }

    write(c(
      "",
      "[Local Virtuoso]",
      paste("Driver =", find_odbc_driver()),
      ""
    ),
    file = local_odbcinst,
    append = TRUE
    )

    invisible(local_odbcinst)
  }



already_set <- function(odbcinst) {
  if (is.null(odbcinst)) {
    return(FALSE)
  }
  if (file.exists(odbcinst)) {
    if (any(grepl("\\[Local Virtuoso\\]", readLines(odbcinst)))) {
      # message("Configuration for Virtuoso found")
      return(TRUE)
    }
  }
  FALSE
}


find_odbc_driver <- function(os = which_os()) {
  lookup <- switch(os,
    osx = c(
      "/usr/lib/virtodbc.so",
      "/usr/local/lib/virtodbc.so", # Mac Homebrew symlink
      file.path(virtuoso_home_osx(), "lib", "virtodbc.so")
    ),
    linux = c(
      "/usr/lib/virtodbc.so",
      "/usr/local/lib/virtodbc.so",
      "/usr/lib/odbc/virtodbc.so",
      "/usr/lib/x86_64-linux-gnu/odbc/virtodbc.so"
    ),
    windows = normalizePath(file.path(
      virtuoso_home_windows(),
      "bin", "virtodbc.dll"
    ),
    mustWork = FALSE
    ),
    "OS not recognized or not supported"
  )
  path_lookup(lookup)
}

path_lookup <- function(paths, target_name = basename(paths[[1]])) {
  i <- vapply(paths, file.exists, logical(1L))
  if (sum(i) < 1) {
    warning(paste("could not automatically locate", target_name),
      call. = FALSE
    )
    return(target_name)
  }

  names(which(i))[[1]]
}



#' @importFrom utils read.table
find_odbcinst <- function() {

  if(is_solaris()){
    warning("Virtuoso not available for Solaris", call. = FALSE)
    return("")
  }

  if (Sys.which("odbcinst") == "") {
    return(normalizePath("~/.odbcinst.ini", mustWork = FALSE))
  }

  ## Otherwise we can use `odbcinst -j` to find odbcinst.ini file
  p <- processx::run("odbcinst", "-j")
  trimws(
    read.table(textConnection(p$stdout),
      skip = 1, sep = ":",
      stringsAsFactors = FALSE
    )[1, 2]
  )
}
