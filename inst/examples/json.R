library(virtuoso)
library(dplyr)

## Transform JSON (or list data) into nquads
x <- jsonlite::read_json("https://raw.githubusercontent.com/ropensci/roregistry/ex/codemeta.json")
write_nquads(x, "ropensci.nq")


## And here we go
vos_start()
con <- vos_connect()
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



## FIXME: In the DSL, the above should be:

# select(name, license, author.familyName) %>%
#        filter(author.familyName == "Boettiger", author.givenName == "Carl") %>%
#        distinct()
