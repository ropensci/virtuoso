
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/cboettig/virtuoso.svg?branch=master)](https://travis-ci.org/cboettig/virtuoso)
[![Coverage
status](https://codecov.io/gh/cboettig/virtuoso/branch/master/graph/badge.svg)](https://codecov.io/github/cboettig/virtuoso?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/virtuoso)](https://cran.r-project.org/package=virtuoso)

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
#> Configuration for Virtuoso found
#> virtuoso already installed.
```

We can now start our Virtuoso server from R:

``` r
vos_start()
#> PROCESS 'virtuoso-t', running, pid 50980.
#> 21:01:50 Server online at 1111 (pid 50980)
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
#>                                                 p                        o
#> 1 http://www.w3.org/1999/02/22-rdf-syntax-ns#type http://schema.org/Person
#> 2                      http://schema.org/jobTitle                Professor
#> 3                          http://schema.org/name                 Jane Doe
#> 4                     http://schema.org/telephone           (425) 123-4567
#> 5                           http://schema.org/url   http://www.janedoe.com
```

We can clear all data in the default graph if we want a fresh start:

``` r
vos_clear_graph(con)
#> data frame with 0 columns and 0 rows
```

## Server controls

We can control any `virtuoso` server started with `vos_start()` using a
series of helper commands.

``` r
vos_status()
#> 21:01:51 PL LOG: No more files to load. Loader has finished,
#> [1] "online"
```

Advanced usage note: `vos_start()` invisibly returns a `processx` object
which we can pass to other server control functions, or access the
embedded `processx` control methods directly. The `virtuoso` package
also caches this object in an environment so that it can be accessed
directly without having to keep track of an object in the global
environment. Use `vos_process()` to return the `processx` object. For
example:

``` r
p <- vos_process()
p$get_error_file()
#> [1] "/var/folders/y8/0wn724zs10jd79_srhxvy49r0000gn/T/RtmpPitaHN/vos_startc68640a64f02.log"
p$suspend()
#> NULL
p$resume()
#> NULL
```

-----

See richer examples in the package vignettes.
