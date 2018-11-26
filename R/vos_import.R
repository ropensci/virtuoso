

#' vos_import
#'
#' @param con a ODBC connection to Virtuoso, from [`vos_connect()`]
#' @param files paths to files to be imported
#' @param wd The directory from which we can search the files.
#' NOTE: This directory must match or be in the directory from which you ran vos_start().
#' This is the default behavior and probably best not altered.
#' @param glob A wildcard aka globbing pattern (e.g. "*.nq").
#' @param graph Name (technically URI) for a graph in the database.  Can leave as default.
#' If a graph is already specified by the import file (e.g. in nquads), that will be used
#' instead.
#'
#' @details the bulk importer technically imports all files matching a pattern in a given
#' directory.  If given a list of files
#'
#' @references http://vos.openlinksw.com/owiki/wiki/VOS/VirtBulkRDFLoader
#' @importFrom digest digest
#' @export
vos_import <- function(con, files = NULL, wd = ".", glob = "*", graph = "rdflib"){

  assert_allowedDirs(wd)

  ## If given a list of specific files

  stopifnot(all(assert_extensions(files))) # could be more helpful error


  ## We have to copy (link) files into the directory Virtuoso can access.
  if(!is.null(files)){
    wd = file.path(vos_cache(), digest::digest(files))
    dir.create(wd, FALSE)
    lapply(files, function(from) file.symlink(from, file.path(wd, basename(from))))
  }

  ## Even on Windows, ld_dir wants a Unix-style path-slash
  if(is_windows()) wd <- normalizePath(wd, winslash = "/")
  DBI::dbGetQuery(con, paste0("ld_dir('", wd, "', '", glob, "', '", graph, "')") )

  ## Can call loader multiple times on multicore to load multiple files...
  DBI::dbGetQuery(con, "rdf_loader_run()" )

  ## clean up cache
  if(!is.null(files)){
    lapply(files, function(f){
      if(basename(f) != f) unlink(file.path(wd, basename(files)))
    })
  }

  ## Check status
  status <- DBI::dbGetQuery(con, paste0("SELECT * FROM DB.DBA.LOAD_LIST"))

  import_errors <-  any(!is.na(status$ll_error))
  if(import_errors){
    stop(paste("Error importing",
               status$ll_file[!is.na(status$ll_error)]),
         call. = FALSE)
  }

  invisible(status)
}

assert_extensions <- function(files){
  known_extensions <- c("grdf", "nq",  "owl", "nt",
                        "rdf", "trig", "ttl", "xml")
  pattern <- paste0("[.]", known_extensions, "(.gz)?$")
  results <-
    vapply(files, function(filename) any(
      vapply(pattern, grepl, logical(1L), filename)),
      logical(1L)
    )

  invisible(results)
}


guess_ext <- function(files){
  filename <- basename(files[[1]])
  ext <- sub(".*([.]\\w+)", "*\\1", filename)
  if(ext == "*.gz"){
    ext <- paste0(sub(".*([.]\\w+)", "*\\1",
                      sub("[.]\\w+$", "", filename)),
                  ".gz")
  }
  ext
}


#' @importFrom fs path_tidy
assert_allowedDirs <- function(wd = ".", db_dir = vos_db()){

  ## In case user connects to external virtuoso
  status <- tryCatch(vos_status(),
                     error = function(e) "not detected",
                     finally = NULL)
  if(status == "not detected"){
    warning(paste("Could not access virtuoso.ini configuration.",
               "If you are using an external virtuoso server,",
               "ensure working directory is in allowedDirs"),
            call. = FALSE)
    return(as.character(NA))
  }

  V <- ini::read.ini(file.path(db_dir, "virtuoso.ini"))
  allowed <- strsplit(V$Parameters$DirsAllowed, ",")[[1]]
  fs::path_tidy(wd) %in% fs::path_tidy(allowed)



}
