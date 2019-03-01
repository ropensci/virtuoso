

#' Bulk Import of RDF triples
#'
#' While triples data can be added one by one over SPARQL queries,
#' Virtuoso bulk import is by far the fastest way to import large
#' triplestores in the database.
#'
#' @param con a ODBC connection to Virtuoso, from [vos_connect()]
#' @param files paths to files to be imported
#' @param wd Alternatively, can specify directory and globbing pattern
#'  to import. Note that in this case, wd must be in (or a subdir of)
#'  the `AllowedDirs` list of `virtuoso.ini` file created by
#'  [vos_configure()]. By default, this includes the working directory
#'  where you called [vos_start()] or [vos_configure()].
#' @param glob A wildcard aka globbing pattern (e.g. `"*.nq"``).
#' @param graph Name (technically URI) for a graph in the database.
#'  Can leave as default. If a graph is already specified by the
#'  import file (e.g. in nquads), that will be used instead.
#' @param n_cores specify the number of available cores for parallel loading.
#' Particularly useful when importing large numbers of bulk files.
#' @return (Invisibly) returns the status table of the bulk loader,
#'  indicating file loading time or errors.
#' @details the bulk importer imports all files matching a pattern
#'  in a given directory.  If given a list of files, these are
#'  temporarily symlinked (or copied on Windows machines) to
#'  the Virtuoso app cache dir in a subdirectory, and the entire
#'  subdirectory is loaded (filtered by the globbing pattern).
#'  If files are not specified, load is called directly on the specified
#'  directory and pattern.  This is particularly useful for loading large
#'  numbers of files.
#'
#'  Note that Virtuoso recommends breaking large files into multiple smaller ones,
#'  which can improve loading time (particularly if using multiple cores.)
#'
#'  Virtuoso Bulk Importer recognizes the following file formats:
#'  - `.grdf`
#'  - `.nq`
#'  - `.owl`
#'  - `.nt`
#'  - `.rdf`
#'  - `.trig`
#'  - `.ttl`
#'  - `.xml`
#'
#'  Any of these can optionally be gzipped (with a `.gz` extension).
#' @references <http://vos.openlinksw.com/owiki/wiki/VOS/VirtBulkRDFLoader>
#' @importFrom digest digest
#' @importFrom fs path_abs
#' @export
#' @examples
#'
#' vos_status()
#'
#' \donttest{
#' if(has_virtuoso()){
#' vos_start()
#' con <- vos_connect()
#'
#' example <- system.file("extdata", "person.nq", package = "virtuoso")
#' vos_import(con, example)
#' }
#' }
vos_import <- function(con,
                       files = NULL,
                       wd = ".",
                       glob = "*",
                       graph = "rdflib",
                       n_cores = 1L) {
  cache <- vos_cache()


  ## If given a list of specific files

  stopifnot(all(assert_extensions(files))) # could be more helpful error


  ## We have to copy (link) files into the directory Virtuoso can access.
  if (!is.null(files)) {
    subdir <- digest::digest(files)
    wd <- file.path(cache, subdir)
    dir.create(wd, showWarnings = FALSE, recursive = TRUE)
    ## NOTE we need abs paths of files for this to work (at least with symlinks)
    lapply(files, function(from) {
      target <- file.path(wd, basename(from))

      ## remove target before symlinking
      if (file.exists(target)) file.remove(target)

      ## symlink only on Unix, must copy on Windows:
      switch(which_os(),
        "windows" = file.copy(fs::path_abs(from), target),
        file.symlink(fs::path_abs(from), target)
      )
    })
  }

  ## Even on Windows, ld_dir wants a Unix-style path-slash
  wd <- fs::path_tidy(wd)
  if (is_windows()) wd <- fs::path_abs(wd)
  DBI::dbGetQuery(
    con,
    paste0(
      "ld_dir('",
      wd,
      "', '",
      glob,
      "', '",
      graph,
      "')"
    )
  )

  importing_files <- fs::dir_ls(wd, glob = glob)

  ## Can call loader multiple times on multicore to load multiple files...
  replicate(n_cores, DBI::dbGetQuery(con, "rdf_loader_run()"))

  ## clean up cache
  if (!is.null(files)) {
    lapply(files, function(f) unlink(file.path(wd, basename(files))))
    unlink(subdir)
  }

  ## Check status. This includes all fils ever imported
  ## Select only those on current import list.
  status <- DBI::dbGetQuery(con, paste0("SELECT * FROM DB.DBA.LOAD_LIST"))
  current <- status$ll_file %in% importing_files
  status <- status[current, ]

  import_errors <- any(!is.na(status$ll_error))
  if (import_errors) {
    err <- status[!is.na(status$ll_error), c("ll_file", "ll_error")]
    stop(paste("Error importing:", paste(basename(err$ll_file), err$ll_error)),
      call. = FALSE
    )
  }

  invisible(status)
}

assert_extensions <- function(files) {
  known_extensions <- c(
    "grdf", "nq", "owl", "nt",
    "rdf", "trig", "ttl", "xml"
  )
  pattern <- paste0("[.]", known_extensions, "(.gz)?$")
  results <-
    vapply(
      files, function(filename) any(
          vapply(pattern, grepl, logical(1L), filename)
        ),
      logical(1L)
    )

  invisible(results)
}


guess_ext <- function(files) {
  filename <- basename(files[[1]])
  ext <- sub(".*([.]\\w+)", "*\\1", filename)
  if (ext == "*.gz") {
    ext <- paste0(
      sub(
        ".*([.]\\w+)", "*\\1",
        sub("[.]\\w+$", "", filename)
      ),
      ".gz"
    )
  }
  ext
}


#' @importFrom fs path_tidy
assert_allowedDirs <- function(wd = ".", db_dir = vos_db()) {

  ## In case user connects to external virtuoso
  status <- vos_status()
  if (is.null(status)) {
    warning(paste(
      "Could not access virtuoso.ini configuration.",
      "If you are using an external virtuoso server,",
      "ensure working directory is in allowedDirs"
    ),
    call. = FALSE
    )
    return(as.character(NA))
  }

  V <- ini::read.ini(file.path(db_dir, "virtuoso.ini"))
  allowed <- strsplit(V$Parameters$DirsAllowed, ",")[[1]]
  fs::path_tidy(wd) %in% fs::path_tidy(allowed)
}
