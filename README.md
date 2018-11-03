
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
#> Configuration for Local Virtuoso found
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
```

## DSL

`virtuoso` also provides wrappers around some common queries to make it
easier to work with Virtuoso and RDF.

The bulk loader can be used to quickly import existing sets of triples.

``` r
example <- system.file("extdata", "person.nq", package = "virtuoso")
vos_import(con, example)
```

``` r
vos_query(con, 
"SELECT ?p ?o 
 WHERE { ?s ?p ?o .
        ?s a <http://schema.org/Person>
       }")
#> [1] p o
#> <0 rows> (or 0-length row.names)
```

We can clear all data in the default graph if we want a fresh start:

``` r
vos_clear_graph(con)
#> data frame with 0 columns and 0 rows
```

Stop the server explicitly (Will otherwise stop when R session ends)

``` r
myserver$kill()
#> [1] FALSE
```

-----

See richer examples in the package vignettes.
