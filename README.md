
[![Travis build
status](https://travis-ci.org/cboettig/virtuoso.svg?branch=master)](https://travis-ci.org/cboettig/virtuoso)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# virtuoso

The goal of virtuoso is to provide an easy interface to Virtuoso RDF
database from R.

## Installation

You can install the development version of virtuoso from GitHub with:

``` r
remotes::install_github("cboettig/virtuoso")
```

## Getting Started

``` r
library(virtuoso)
```

For Mac users, `virtuoso` package includes a utility function to install
and configure a local Virtuoso Open Source instance using Homebrew.
Otherwise, simply install the Virtuoso Open Source edition for your
operating system.

``` r
vos_install()
#> virtuoso already installed.
```

We can now start a server. (Here we assign the server process to an
object, `myserver` which we can use to stop or control it explicitly, if
necessary). Note that the server may take a few seconds to come up.

``` r
myserver <- vos_start()

Sys.sleep(5)
```

Once the server is running, we can connect to the database.

``` r
con <- vos_connect()
```

Our connection is now live, and accepts SPARQL queries directly.

``` r
ex <- DBI::dbGetQuery(con, "SPARQL SELECT * WHERE { ?s ?p ?o }")
head(ex)
#>                                                                              s
#> 1                   http://www.openlinksw.com/virtrdf-data-formats#default-iid
#> 2          http://www.openlinksw.com/virtrdf-data-formats#default-iid-nullable
#> 3          http://www.openlinksw.com/virtrdf-data-formats#default-iid-nonblank
#> 4 http://www.openlinksw.com/virtrdf-data-formats#default-iid-nonblank-nullable
#> 5                       http://www.openlinksw.com/virtrdf-data-formats#default
#> 6              http://www.openlinksw.com/virtrdf-data-formats#default-nullable
#>                                                 p
#> 1 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 2 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 3 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 4 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 5 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 6 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#>                                                         o
#> 1 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 2 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 3 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 4 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 5 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 6 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
```

## DSL

`virtuoso` also provides wrappers around some common queries to make it
easier to work with Virtuoso and RDF.

The bulk loader can be used to quickly import existing sets of triples.

``` r
example <- system.file("extdata", "person.nq", package = "virtuoso")
vos_import(con, example)
```

We can clear all data in the default graph if we want a fresh start:

``` r
vos_clear_graph(con)
#> data frame with 0 columns and 0 rows
```

-----

## Tabular data as RDF?

We can represent any data as RDF with a little care. For instance,
consider the `nycflights13` data.

``` r
library(nycflights13)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

First, we must represent any primary or foreign keys in any table must
be as URIs and not literal integers or strings:

``` r
uri_flights <- flights %>% 
  mutate(tailnum = paste0("planes:", tailnum),
         carrier = paste0("airlines:", carrier))
```

We write the `data.frame`s out as nquads. Recall that each cell of a
`data.frame` can be represented as a triple, in which the column is the
predicate, the primary key (or row number) the subject, and the cell
value the object. We turn column names and primary keys into URIs using
a prefix based on the table name. (Note that `rdflib` does this
conversion by merely munging cells and calling `write.table`, it is not
a standard `redland` library
transform).

``` r
write_nquads(airlines,  "airlines.nq", key = "carrier", prefix = "airlines:")
write_nquads(planes,  "planes.nq", key = "tailnum", prefix = "planes:")
write_nquads(uri_flights,  "flights.nq", prefix = "flights:")
```

We’re ready to import all these triples. This may take a few minutes:

``` r
system.time(
  vos_import(con, c("flights.nq", "planes.nq", "airlines.nq"))
)
#>    user  system elapsed 
#>   0.002   0.094 151.469
```

The data from all three tables is now reduced into a single triplestore
graph, one triple for each data point. Rather than joining tables, we
can write SPARQL query that names the columns we want.

``` r

query <- 
'SELECT  ?carrier ?name ?manufacturer ?model ?dep_delay
WHERE {
?flight <flights:tailnum>  ?tailnum .
?flight <flights:carrier>  ?carrier .
?flight <flights:dep_delay>  ?dep_delay .
?tailnum <planes:manufacturer> ?manufacturer .
?tailnum <planes:model> ?model .
?carrier <airlines:name> ?name
}'

system.time(
df <- vos_query(con, query)
)
#>    user  system elapsed 
#>   3.461   0.518  22.494

head(df)
#>       carrier                     name     manufacturer     model
#> 1 airlines:EV ExpressJet Airlines Inc.          EMBRAER EMB-145XR
#> 2 airlines:EV ExpressJet Airlines Inc.          EMBRAER EMB-145LR
#> 3 airlines:EV ExpressJet Airlines Inc.          EMBRAER EMB-145LR
#> 4 airlines:US          US Airways Inc. AIRBUS INDUSTRIE  A320-214
#> 5 airlines:EV ExpressJet Airlines Inc.          EMBRAER EMB-145XR
#> 6 airlines:EV ExpressJet Airlines Inc.          EMBRAER EMB-145XR
#>   dep_delay
#> 1        11
#> 2        14
#> 3        -6
#> 4        -3
#> 5        -2
#> 6        -4
```
