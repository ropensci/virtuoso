
#' Run SPARQL query
#'
#' @param query a SPARQL query statement
#' @inheritParams vos_import
#' @export
vos_query <- function(con, query, graph = "rdflib"){
  ## FIXME construct SQL query more nicely with existing parsers
  DBI::dbGetQuery(con, paste0("SPARQL ",  query))
}

#' Clear all triples from a graph
#'
#' @details NOTE: after clearing a graph, re-running the bulk importer may not
#' re-import triples, at least until virtuoso-server is restarted.
#' @export
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
vos_delete_db <- function(ask = interactive(), db_dir = vos_db()){
  if(ask)
    continue <- utils::askYesNo("Are you sure?")
  if(continue)
    unlink(db_dir, recursive = TRUE)
}


#' List graphs
#'
#' @export
#' @inheritParams vos_import
vos_list_graphs <- function(con){
  DBI::dbGetQuery(con,
           "SPARQL SELECT  DISTINCT ?g WHERE { GRAPH ?g {?s ?p ?o} } ORDER BY ?g"
)
}

vos_count_triples <- function(con){
  ## Official queries, not sure why these return large negative integer
  #DBI::dbGetQuery(con, "SPARQL SELECT COUNT(*) FROM <rdflib>")
  #DBI::dbGetQuery(con, "SPARQL SELECT (COUNT(?s) AS ?triples) WHERE { GRAPH ?g { ?s ?p ?o } }")

  ## Seems to be correct total, but not the number of distinct
  DBI::dbGetQuery(con, "SPARQL SELECT DISTINCT (COUNT(?s) AS ?triples) WHERE { ?s ?p ?o }")

  ## Return all triples and count by graph in R. Must fit in memory :(
  ## df <- DBI::dbGetQuery(con, "SPARQL SELECT ?g ?s ?p ?o  WHERE { GRAPH ?g {?s ?p ?o} }")
  ## dplyr::count_(df, "g")
}







