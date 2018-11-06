library(virtuoso)
library(rdftools) # for write_nquads
library(dplyr)

## Transform JSON (or list data) into nquads
x <- jsonlite::read_json("https://raw.githubusercontent.com/ropensci/roregistry/ex/codemeta.json")
virtuoso::write_nquads(x, "ropensci.nq", prefix = "http://schema.org/")


## And here we go
vos_start()
con <- vos_connect()

virtuoso:::vos_count_triples(con)
vos_import(con, "ropensci.nq")


## Find all packages where Carl Boettiger is an author, and return:
## package name, license, and co-author surnames
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
vos_query(con, query) %>% as_tibble() %>% mutate(license = basename(license))




### DSL Proof of Principle
source("R/select_.R")
source("R/filter_.R")

query <-
  sparql_op() %>%
  select.vos("identifier", "license", prefix = "http://schema.org/") %>%
  filter.vos(author.familyName == "Boettiger",
             author.givenName == "Carl",
             prefix = "http://schema.org/") %>%
  sparql_build()

vos_query(con, query)



query <-
        sparql_op() %>%
        select.vos(package = "name", "license", "author.familyName", "author.givenName",
                   co = "author.familyName",
                   prefix = "http://schema.org/") %>%
        filter.vos( author.givenName == "Carl",
                    author.familyName == "Boettiger",
                   prefix = "http://schema.org/") %>%
        sparql_build()

vos_query(con, query)
