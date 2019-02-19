## ROpenSci Registry as NQuads
library(jsonlite)
library(jsonld)
library(purrr)

download.file("https://raw.githubusercontent.com/ropensci/roregistry/gh-pages/raw_cm.json", "raw_cm.json")

## Most efficient solution:
jsonld::jsonld_to_rdf("raw_cm.json") %>% writeLines("ro.nq.gz")


## Alternate workflow I
##  Expand and compact is a good way to remove duplicate contexts
x <- jsonlite::read_json("raw_cm.json")
expanded <- x %>%
  map(
    function(y){ y %>%
        toJSON(auto_unbox = TRUE) %>%
        jsonld_expand("https://raw.githubusercontent.com/codemeta/codemeta/2.0/codemeta.jsonld") %>%
        fromJSON()
    })
jsonlite::write_json(list("@graph" = expanded), "expanded.json", auto_unbox=TRUE, pretty=TRUE)
flat_list <- jsonld::jsonld_flatten("json/raw_cm.json") %>% fromJSON(simplifyDataFrame = FALSE)


## Alternative workflow II

## roundtrip to reverse the rectangling created by fromJSON DataFrame simplification
unsimplifyJSON <- function(df){
  df %>% toJSON()  %>%
    fromJSON(simplifyDataFrame = FALSE) %>%
    map(flatten)
}

as_uri <- function(x){
  if(!is.list(x)) return(x)
  x[map_lgl(x, is.null)] <- NA
  y <- flatten(x)
  not_uri <- !grepl("^http", y)
  y[not_uri] <- NA
  flatten_chr(y)
}


flat <- jsonld::jsonld_flatten("raw_cm.json") %>% fromJSON()
flat$`http://schema.org/license` <- as_uri(flat$`http://schema.org/license`)
flat_list <- unsimplifyJSON(flat)
rdftools::write_nquads(flat_list, "roregistry.nq.gz", prefix="registry:")
