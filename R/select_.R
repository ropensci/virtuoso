
#' sparql_select("name", "license", "author.familyName")
#'
#' rename a variable
#' sparql_select(package = "name", "license", coauthor = "author.familyName") %>%
#' sparql_filter(author.familyName == "Boettiger", author.givenName == "Carl") %>%
#' sparql_build()

sparql_op <- function(select = character(), where = character(), from = character()){
  structure(list(select = select, where = where, from = from), class = "op_sparql")
}

c.op_sparql <- function(...){
  dots <- list(...)
  keys <- unique(unlist(lapply(dots, names)))
  out <- setNames(do.call(mapply, c(FUN = c, lapply(dots, `[`, keys))), keys)
  structure(lapply(out, function(x) as.character(na.omit(x))),class = "op_sparql")
  }

sparql_select <- function(..., prefix = NULL, na.rm = TRUE){

  input <- c(...)
  variable <- names(input)

  where <- unlist(lapply(seq_along(input), function(i)
    build_filter(input[[i]], variable = variable[[i]], prefix = prefix)))
  select <- stringi::stri_extract_last_regex(input, pattern = "\\w+$")


  sparql_op(select, where)
}




sparql_build <- function(op, na.rm = TRUE){

  where <- op$where

  if (!na.rm) where <- optional(where)
  where <- paste(where, collapse = " .\n")
  query <- paste0("SELECT", " ", paste0("?", op$select, collapse = " "),
                 "\nWHERE {\n", where, "\n}")

  class(query) <- c("sparql", "sql", "character")
  query
}

print.sparql <- function(x, ...) cat(format(x, ...), sep = "\n")
format.sparql <- function (x, ...)
{
  if (length(x) == 0) {
    paste0("<SPARQL> [empty]")
  }
  else {
    paste0("<SPARQL> ", x)
  }
}


## go from "name" to "?s <name> ?name"
#' @importFrom stringi stri_split_fixed
predicate_filter <- function(predicate, subject = "s", prefix = NULL, query = NULL){

  p <- stringi::stri_split_fixed(predicate, pattern = ".", n = 2)[[1]]

  predicate <- p[[1]]
  query <- c(query,
             paste0("?", subject,
                    " ", uri_format(predicate, prefix), " ",
                    "?", predicate)
             )
  if (length(p) > 1)
    return(predicate_filter(p[[2]], subject = p[[1]],
                            prefix = prefix, query = query) )

  query
}

uri_format <- function(string, prefix = NULL){
  if (!is.null(prefix) & !grepl(":", string))
    string <- paste0(prefix, ":", string)
  if(!grepl("^<.*>$", string))
    string <- paste0("<", string, ">")
  string
}

optional <- function(where) paste("OPTIONAL {", where, "}")


