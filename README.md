
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/cboettig/virtuoso.svg?branch=master)](https://travis-ci.org/cboettig/virtuoso)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/cboettig/virtuoso?branch=master&svg=true)](https://ci.appveyor.com/project/cboettig/virtuoso)
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
```

We can now start our Virtuoso server from R:

``` r
vos_start()
#> PROCESS 'virtuoso-t', running, pid 39981.
#> Server is now starting up, this may take a few seconds...
#> latest log entry: 22:36:36 Server online at 1111 (pid 39981)
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

Can also read in compressed formats as well. Remeber to set the pattern
match appropriately. This is convient becuase N-Quads compress
particularly well, often by a factor of 20 (or rather, can be
particularly large when uncompressed, owing to the repeated property and
subject URIs).

``` r
ex <- system.file("extdata", "library.nq.gz", package = "virtuoso")
vos_import(con, ex)
```

The import process is run by the external process, it will not throw an
error if the server fails to import the file (e.g. due to formatting
errors in the N-Quads file). We can optionally check for possible error
messages in the import process by scanning the full log for errors:

``` r
vos_log(just_errors = TRUE)
#> character(0)
```

We can now query the imported data using SPARQL.

``` r
vos_query(con, 
"SELECT ?p ?o 
 WHERE { ?s ?p ?o .
        ?s a <http://schema.org/Person>
       }")
#>                                                 p                        o
#> 1 http://www.w3.org/1999/02/22-rdf-syntax-ns#type http://schema.org/Person
#> 2                          http://schema.org/name                 Jane Doe
#> 3                      http://schema.org/jobTitle                Professor
#> 4                     http://schema.org/telephone           (425) 123-4567
#> 5                           http://schema.org/url   http://www.janedoe.com
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
#> latest log entry: 22:36:42 PL LOG: No more files to load. Loader has finished,
#> [1] "running"
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
#> [1] "/var/folders/y8/0wn724zs10jd79_srhxvy49r0000gn/T/RtmprWGF3p/vos_start99bdfff46c2.log"
p$suspend()
#> NULL
p$resume()
#> NULL
```

-----

See richer examples in the [package
vignettes](https://cboettig.github.io/virtuoso/articles).
