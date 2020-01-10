
# virtuoso <img src="man/figures/logo.svg" align="right" alt="" width="120" />

[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.org/ropensci/virtuoso.svg?branch=master)](https://travis-ci.org/ropensci/virtuoso)
[![Build
status](https://ci.appveyor.com/api/projects/status/x5r18x1cvu6khksd/branch/master?svg=true)](https://ci.appveyor.com/project/cboettig/virtuoso/branch/master)
[![Coverage
status](https://codecov.io/gh/ropensci/virtuoso/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/virtuoso?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/virtuoso)](https://cran.r-project.org/package=virtuoso)
[![Peer
review](http://badges.ropensci.org/271_status.svg)](https://github.com/ropensci/software-review/issues/271)

<!-- README.md is generated from README.Rmd. Please edit that file -->

The goal of virtuoso is to provide an easy interface to Virtuoso RDF
database from R.

## Installation

You can install the development version of virtuoso from GitHub with:

``` r
remotes::install_github("ropensci/virtuoso")
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
#> Virtuoso is already installed.
```

We can now start our Virtuoso server from R:

``` r
vos_start()
#> Virtuoso is already running with pid: 11624
```

Once the server is running, we can connect to the database.

``` r
con <- vos_connect()
```

Our connection is now live, and accepts SPARQL queries directly.

``` r
DBI::dbGetQuery(con, "SPARQL SELECT * WHERE { ?s ?p ?o } LIMIT 4")
#>                                                                              s
#> 1                   http://www.openlinksw.com/virtrdf-data-formats#default-iid
#> 2          http://www.openlinksw.com/virtrdf-data-formats#default-iid-nullable
#> 3          http://www.openlinksw.com/virtrdf-data-formats#default-iid-nonblank
#> 4 http://www.openlinksw.com/virtrdf-data-formats#default-iid-nonblank-nullable
#>                                                 p
#> 1 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 2 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 3 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 4 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#>                                                         o
#> 1 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 2 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 3 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
#> 4 http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat
```

## DSL

`virtuoso` also provides wrappers around some common queries to make it
easier to work with Virtuoso and RDF.

The bulk loader can be used to quickly import existing sets of triples.

``` r
example <- system.file("extdata", "person.nq", package = "virtuoso")
vos_import(con, example)
```

Can also read in compressed formats as well. Remember to set the pattern
match appropriately. This is convenient because N-Quads compress
particularly well, often by a factor of 20 (or rather, can be
particularly large when uncompressed, owing to the repeated property and
subject URIs).

``` r
ex <- system.file("extdata", "library.nq.gz", package = "virtuoso")
vos_import(con, ex)
```

`vos_import` invisibly returns a table of the loaded files, with error
message and loading times. If a file cannot be imported, an error
message is returned:

``` r
bad_file <- system.file("extdata", "bad_quads.nq", package = "virtuoso")
vos_import(con, bad_file)
#> Error: Error importing: bad_quads.nq 37000 SP029: NQuads RDF loader, line 2: Undefined namespace prefix at ITIS:1000000
```

We can now query the imported data using SPARQL.

``` r
df <- vos_query(con, 
"SELECT ?p ?o 
 WHERE { ?s ?p ?o .
        ?s a <http://schema.org/Person>
       }")
head(df)
#>                                                 p
#> 1 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 2                         http://schema.org/email
#> 3                    http://schema.org/familyName
#> 4                     http://schema.org/givenName
#> 5 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 6                         http://schema.org/email
#>                                   o
#> 1          http://schema.org/Person
#> 2             blake.seers@gmail.com
#> 3                             Seers
#> 4                             Blake
#> 5          http://schema.org/Person
#> 6 hajk-georg.drost@tuebingen.mpg.de
```

``` r
vos_query(con, 
"SELECT ?p ?o 
 WHERE { ?s ?p ?o .
        ?s a <http://example.org/vocab#Chapter>
       }")
#>                                                 p
#> 1 http://www.w3.org/1999/02/22-rdf-syntax-ns#type
#> 2     http://purl.org/dc/elements/1.1/description
#> 3           http://purl.org/dc/elements/1.1/title
#>                                          o
#> 1         http://example.org/vocab#Chapter
#> 2 An introductory chapter on The Republic.
#> 3                         The Introduction
```

## Server controls

We can control any `virtuoso` server started with `vos_start()` using a
series of helper commands.

``` r
vos_status()
#> latest log entry: 19:11:55 PL LOG: No more files to load. Loader has finished,
#> [1] "sleeping"
```

Advanced usage note: `vos_start()` invisibly returns a `processx` object
which we can pass to other server control functions, or access the
embedded `processx` control methods directly. The `virtuoso` package
also caches this object in an environment so that it can be accessed
directly without having to keep track of an object in the global
environment. Use `vos_process()` to return the `processx` object. For
example:

``` r
library(ps)
p <- vos_process()
ps_is_running(p)
#> [1] TRUE
ps_cpu_times(p)
#>            user          system    childen_user children_system 
#>            2.36            0.32            0.00            0.00
ps_suspend(p)
#> NULL
ps_resume(p)
#> NULL
```

## Going further

Please see the package vignettes for more information:

  - [details on Virtuoso Installation &
    configuration](https://ropensci.github.io/virtuoso/articles/installation.html)
  - [The Data Lake: richer examples of RDF
    use](https://ropensci.github.io/virtuoso/articles/articles/datalake.html)

-----

Please note that the `virtuoso` R package is released with a
[Contributor Code of
Conduct](https://docs.ropensci.org/virtuoso/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its
terms.

[![ropensci\_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
