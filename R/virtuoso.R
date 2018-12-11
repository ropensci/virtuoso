## Some possible helper routines for common requests.

#' Clear all triples from a graph
#'
#' @details NOTE: after clearing a graph, re-running the bulk
#' importer may not re-import triples.
#' @inheritParams vos_import
vos_clear_graph <- function(con, graph = "rdflib"){
  DBI::dbGetQuery(con, paste0("SPARQL CLEAR GRAPH <", graph, ">"))
}

#' Delete Virtuoso Database
#'
#' delete the entire Virtuoso database for a fresh start.
#' @param ask prompt before deleting?
#' @param db_dir location of the directory to delete
#' @export
vos_delete_db <- function(ask = interactive(),
                          db_dir = vos_db()){
  if(ask)
    continue <- askYesNo("Are you sure?")
  if(continue)
    unlink(db_dir, recursive = TRUE)
}


#' List graphs
#'
#' @export
#' @inheritParams vos_import
vos_list_graphs <- function(con){
  DBI::dbGetQuery(con,
     paste("SPARQL SELECT",
           "DISTINCT ?g",
           "WHERE {",
           "GRAPH ?g {?s ?p ?o}",
           "}",
           "ORDER BY ?g")
          )
}


## Methods not yet implemented, see notes inline.

#' count triples
#'
#' @inheritParams vos_import
vos_count_triples <- function(con, graph = NULL){

  ## Official query method below.  Not sure why these return
  ## large negative integer on debian and fail on mac...
  #DBI::dbGetQuery(con, "SPARQL SELECT COUNT(*) FROM <rdflib>")
  #DBI::dbGetQuery(con, paste("SPARQL SELECT (COUNT(?s) AS ?triples)",
  ## "WHERE { GRAPH ?g { ?s ?p ?o } }"))

  ## this way with dplyr way works but requires in-memory
  ## loading of all triples, probably a terrible idea!
  ## df <- DBI::dbGetQuery(con, paste(
  ## "SPARQL SELECT ?g ?s ?p ?o  WHERE { GRAPH ?g {?s ?p ?o} }"))
  ## dplyr::count_(df, "g")

}







