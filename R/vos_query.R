
#' Run a SPARQL query
#'
#' @param query a SPARQL query statement
#' @inheritParams vos_import
#' @return a `data.frame` containing the results of the query
#' @details SPARQL is a graph query language similar in syntax SQL,
#' but allows the use of variables to walk through graph nodes.
#' @seealso [vos_start()], [vos_connect()]
#' @references
#' - <https://en.wikipedia.org/wiki/SPARQL>
#' - <https://docs.ropensci.org/rdflib/articles/rdf_intro.html>
#'
#' @examples
#' vos_status()
#' \donttest{
#' if(has_virtuoso()){
#' vos_start()
#' con <- vos_connect()
#'
#' # show first 4 triples in the database
#' DBI::dbGetQuery(con, "SPARQL SELECT * WHERE { ?s ?p ?o } LIMIT 4")
#' }
#' }
#' @export
vos_query <- function(con, query) {
  DBI::dbGetQuery(con, paste0("SPARQL ", query))
}
