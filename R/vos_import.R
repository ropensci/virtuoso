

#' vos_import
#'
#' @param con a ODBC connection to Virtuoso, from [`vos_connect()`]
#' @param files paths to files to be imported
#' @param wd The directory from which we can search the files.
#' NOTE: This directory must match or be in the directory from which you ran vos_start().
#' This is the default behavior and probably best not altered.
#' @param ext glob and extension to match file types. Will guess based on files specified
#' @param graph Name (technically URI) for a graph in the database.  Can leave as default.
#'
#' @export
vos_import <- function(con, files, wd = ".", ext = NULL, graph = "rdflib"){

  stopifnot(all(assert_extensions(files))) # could be more helpful error
  if (is.null(ext)) ext <- guess_ext(files)



  ## We have to copy files into the directory Virtuoso can access.
  ## This is the directory where virtuoso.ini is located.
  if(!dir.exists(wd)) dir.create(wd)
  ## Can we use file.symlink instead of copy?
  lapply(files, function(from) file.copy(from, file.path(wd, basename(from))))

  ## Even on Windows, ld_dir wants a Unix-style path-slash
  if(is_windows()) wd <- normalizePath(wd, winslash = "/")

  DBI::dbGetQuery(con, paste0("ld_dir('", wd, "', '", ext, "', '", graph, "')") )

  ## Can call loader multiple times on multicore to load multiple files...
  DBI::dbGetQuery(con, "rdf_loader_run()" )

  ## clean up
  lapply(files, function(f){
    if(basename(f) != f) unlink(file.path(wd, basename(files)))
  })
  invisible(files)
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
