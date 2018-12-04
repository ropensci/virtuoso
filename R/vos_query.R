
#' Run SPARQL query
#'
#' @param query a SPARQL query statement
#' @inheritParams vos_import
#' @export
vos_query <- function(con, query){
  DBI::dbGetQuery(con, paste0("SPARQL ",  query))
}
