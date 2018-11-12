

#' vos_import
#'
#' @param con a ODBC connection to Virtuoso, from [`vos_connect()`]
#' @param files paths to files to be imported
#' @param wd The directory from which we can search the files.
#' NOTE: This directory must match or be in the directory from which you ran vos_start().
#' This is the default behavior and probably best not altered.
#' @param ext glob and extension to match file types. Defaults to match any nquads.
#' @param graph Name (technically URI) for a graph in the database.  Can leave as default.
#'
#' @export
vos_import <- function(con, files, wd = ".", ext = "*.nq", graph = "rdflib"){
  ## We have to copy files into the directory Virtuoso can access.
  ## This is the directory where virtuoso.ini is located.
  if(!dir.exists(wd)) dir.create(wd)
  ## Can we use file.symlink instead of copy?
  lapply(files, function(from) file.copy(from, file.path(wd, basename(from))))

  ## Even on Windows, ld_dir wants a Unix-style path-slash
  if(is_windows()) wd <- normalizePath(wd, winslash = "/")

  DBI::dbGetQuery(con, paste0("ld_dir('", wd, "', '", ext, "', '", graph, "')") )
  DBI::dbGetQuery(con, "rdf_loader_run()" )

  ## clean up
  lapply(files, function(f){
    if(basename(f) != f) unlink(file.path(wd, basename(files)))
  })
  invisible(files)
}

