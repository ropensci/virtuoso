


library(virtuoso)
library(rdftools) # for write_nquads
library(dplyr)

## Transform JSON (or list data) into nquads
x <- jsonlite::read_json(paste0(
  "https://raw.githubusercontent.com/",
  "ropensci/roregistry/ex/codemeta.json"
))
virtuoso::write_nquads(x,
                       "ropensci.nq",
                       prefix = "http://schema.org/")

## And here we go
vos_start()
con <- vos_connect()
vos_import(con, "ropensci.nq")


## Find all packages where Carl Boettiger is an author,
## and return: package name, license, and co-author surnames
query <-
  "PREFIX schema: <http://schema.org/>
SELECT DISTINCT ?package ?license ?coauthor
 WHERE {
 ?s schema:identifier ?package ;
    schema:author ?author ;
    schema:license ?license ;
    schema:name ?name ;
    schema:author ?coauth .
 ?author schema:givenName 'Carl' .
 ?author schema:familyName 'Boettiger' .
 ?coauth schema:familyName ?coauthor
}"

vos_query(con, query) %>%
  as_tibble() %>%
  mutate(license = basename(license))




query <-
  rdftools:::sparql_op() %>%
  rdftools:::select("identifier",
                    "license",
                    prefix = "http://schema.org/") %>%
  rdftools:::filter(author.familyName == "Boettiger",
    author.givenName == "Carl",
    prefix = "http://schema.org/"
  ) %>%
  rdftools:::sparql_build()

vos_query(con, query)
