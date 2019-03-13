## Some additional possible helper routines for common requests are shown here.
## Currently not fully developed or tested, and thus not exported.

#' Clear all triples from a graph
#'
#' @details NOTE: after clearing a graph, re-running the bulk
#' importer may refuse to re-import triples.
#' @inheritParams vos_import
#' @examples
#' vos_status()
#' \donttest{
#' if(has_virtuoso()){
#' vos_start()
#' con <- vos_connect()
#' vos_clear_graph(con)
#' }}
#' @noRd
vos_clear_graph <- function(con, graph = "rdflib") {
  DBI::dbGetQuery(con, paste0("SPARQL CLEAR GRAPH <", graph, ">"))
}



#' List graphs
#'
#' @export
#' @inheritParams vos_import
#' @examples
#' vos_status()
#' \donttest{
#' if(has_virtuoso()){
#' vos_start()
#' con <- vos_connect()
#' vos_list_graphs(con)
#'
#' }}
vos_list_graphs <- function(con) {
  DBI::dbGetQuery(
    con,
    paste(
      "SPARQL SELECT",
      "DISTINCT ?g",
      "WHERE {",
      "GRAPH ?g {?s ?p ?o}",
      "}",
      "ORDER BY ?g"
    )
  )
}


## Methods not yet implemented, see notes inline.

#' count triples
#'
#' @inheritParams vos_import
#' @noRd
vos_count_triples <- function(con, graph = NULL) {

  ## Official query method below.  Not sure why these return
  ## large negative integer on debian and fail on mac...
  # DBI::dbGetQuery(con, "SPARQL SELECT COUNT(*) FROM <rdflib>")
  # DBI::dbGetQuery(con, paste("SPARQL SELECT (COUNT(?s) AS ?triples)",
  ## "WHERE { GRAPH ?g { ?s ?p ?o } }"))

  ## this way with dplyr way works but requires in-memory
  ## loading of all triples, probably a terrible idea!
  ## df <- DBI::dbGetQuery(con, paste(
  ## "SPARQL SELECT ?g ?s ?p ?o  WHERE { GRAPH ?g {?s ?p ?o} }"))
  ## dplyr::count_(df, "g")
}
