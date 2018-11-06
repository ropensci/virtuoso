
select.vos <- function(op, ..., prefix = NULL, na.rm = TRUE){
  combine_ops(op,
              sparql_select(..., prefix = prefix, na.rm = na.rm))
}


sparql_select <- function(..., prefix = NULL, na.rm = TRUE){
  ## FIXME adapt to work with bare names.
  input <- c(...)
  variable <- names(input)

  where <- unlist(lapply(seq_along(input), function(i)
    build_filter(input[[i]], variable = variable[[i]], prefix = prefix)))
  select <- stringi::stri_extract_last_regex(input, pattern = "\\w+$")

  sparql_op(select, where)
}


sparql_op <- function(select = character(), where = character(), from = character()){
  structure(list(select = select, where = where, from = from), class = c("vos"))
}

#' @importFrom stats na.omit setNames
combine_ops <- function(...){
  dots <- list(...)
  keys <- unique(unlist(lapply(dots, names)))
  out <- setNames(do.call(mapply, c(FUN = c, lapply(dots, `[`, keys))), keys)
  structure(lapply(out, function(x) as.character(unique(na.omit(x)))),class = c("vos"))
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


uri_format <- function(string, prefix = NULL){
  if (!is.null(prefix)){
    if(!grepl("://", prefix) && !grepl(":", string)){
      string <- paste0(prefix, ":", string)
    } else if (grepl(":", prefix)){
    string <- paste0(prefix, string)
    }
  }
  if(!grepl("^<.*>$", string))
    string <- paste0("<", string, ">")
  string
}

optional <- function(where) paste("OPTIONAL {", where, "}")

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








## DEVELOPER NOTE: Replaced by generalized version build_filter
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


