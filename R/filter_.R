

sparql_filter <- function(..., prefix = NULL){
  dots <- rlang::enexprs(...)


  where <- as.character(unlist(lapply(dots, function(x)
    build_filter(predicate = as.character(x[[2]]),
                  object = x[[3]],
                  fn = as.character(x[[1]])
                  )
         )))

  sparql_op(where = where)

}
# sparql_filter(author.familyName == "Boettiger", author.givenName == "Carl")




## go from "name" to "?s <givenName> 'bob'"
#' @importFrom stringi stri_split_fixed
build_filter <- function(predicate,
                         subject = "s",
                         object = NULL,
                         fn = NULL,
                         variable = NULL,
                         prefix = NULL,
                         query = NULL){

  p <- stringi::stri_split_fixed(predicate, pattern = ".", n = 2)[[1]]

  predicate <- p[[1]]

  ## FIXME this code stinks

  if (!is.null(object) && length(p) == 1) {
    set_object <- paste0("'", object, "'")
  } else if (length(p) > 1) {
    set_object <- paste0("?", non_empty(variable, p[[1]]))
  } else {
    set_object <- paste0("?", p[[1]])

  }


  query <- c(query,
             paste0("?", subject,
                    " ", uri_format(predicate, prefix), " ",
                    set_object)
  )


  if (length(p) > 1)
    return(build_filter(p[[2]],
                        subject = non_empty(variable, p[[1]]),
                        object = object,
                        fn = fn,
                        variable = variable,
                        prefix = prefix,
                        query = query) )

  query
}

non_empty <- function(x, y){
  if (is.null(x)) return(y)
  if (length(x) == 0 ) return(y)
  if (x == "") return(y)
  paste0(x, "_", y)
}
