Submitting Author: Carl Boettiger (@cboettig)
Repository: <https://github.com/cboettig/virtuoso>
Version submitted: 0.1.1 (tagged)
Editor: TBD
Reviewer 1: TBD
Reviewer 2: TBD
Archive: TBD
Version accepted: TBD

---

-   Paste the full DESCRIPTION file inside a code block below:

```
Package: virtuoso
Type: Package
Title: R interface to Virtuoso using ODBC
Version: 0.1.1
Authors@R: c(person("Carl", "Boettiger", 
                  email = "cboettig@gmail.com", 
                  role = c("aut", "cre", "cph"),
                  comment = c(ORCID = "0000-0002-1642-628X")),
             person("Bryce", "Mecum", 
                    role = "ctb", 
                    email = "brycemecum@gmail.com",
                    comment = c(ORCID = "0000-0002-0381-3766")))
Description: Virtuoso is a high-performance "universal server," which can act
             as both a relational database (supporting standard SQL queries),
             and an Resource Description Framework (RDF) triplestore, supporting 
             SPARQL queries and semantic reasoning. The virtuoso package R provides
             R users with a DBI-compatible connection to the Virtuoso database. 
             The package also provides helper routines to install, launch, and manage
             a Virtuoso server locally on Mac, Windows and Linux platforms using
             the standard interactive installers from the R command-line.  By 
             automatically handling these setup steps, the package can make Virtuoso
             considerably faster and easier for a most users to deploy in a local
             environment. While this can be used as a normal dplyr backend, Virtuoso 
             excels when used as a RDF triplestore.  Managing the bulk import of triples
             from common serializations with a single intuitive command is another key
             feature of the Virtuoso R package.  Bulk import performance can be tens to
             hundreds of times faster than the comparable imports using existing R tools,
             including rdflib and redland packages.  
License: MIT + file LICENSE
Encoding: UTF-8
LazyData: true
Imports: 
    odbc,
    processx,
    DBI,
    utils,
    ini,
    rappdirs,
    curl,
    fs,
    digest
RoxygenNote: 6.1.1
Suggests: 
    knitr,
    rmarkdown,
    nycflights13,
    testthat,
    covr,
    jsonld,
    rdftools,
    dplyr,
    spelling
VignetteBuilder: knitr
Remotes: cboettig/rdftools
Language: en-US

```


## Scope

- Please indicate which category or categories from our [package fit policies](https://ropensci.github.io/dev_guide/policies.html#package-categories) this package falls under: (Please check an appropriate box below. If you are unsure, we suggest you make a pre-submission inquiry.):

	- [ ] data retrieval
	- [x] data extraction
	- [x] database access
	- [ ] data munging
	- [ ] data deposition
	- [ ] reproducibility
	- [ ] geospatial data
	- [ ] text analysis


- Explain how the and why the package falls under these categories (briefly, 1-2 sentences):

R users confronted with large dump of triples (e.g. nquad, owl, or other file) currently have few ways of reading in this data,
and no performant option that can handle the huge file sizes frequently involved that do not fit into memory. This package provides
a relatively convenient way to import this data into an RDF-capable database and query that data directly from R.  

-   Who is the target audience and what are scientific applications of this package?

Researchers working with RDF / semantic data.

-   Are there other R packages that accomplish the same thing? If so, how does yours differ or meet [our criteria for best-in-category](https://github.com/ropensci/onboarding/blob/master/policies.md#overlap)?

This package overlaps with ropensci package `rdflib` (and thus `redland`, which is `rdflib` uses under the hood.), which primarily provides an in-memory model for working with RDF data, which fails with large triplestores.  `rdflib` & `redland` do have a pluggable backend that can connect to Virtuoso and other databases, but this is not only very complicated to set up (not only does `redland` R package need to be built from source, but so does the redland C library in some cases) but is also much slower.  This package handles the installation easily in a user-friendly and more performant way, and the resulting Virtuoso server can then be used as a backend to `rdflib` (though there is usually little reason to do so since Virtuoso can be called directly though this package already).  

-   If you made a pre-submission enquiry, please paste the link to the corresponding issue, forum post, or other discussion, or @tag the editor you contacted.

## Technical checks

Confirm each of the following by checking the box.  This package:

- [x] does not violate the Terms of Service of any service it interacts with.
- [x] has a CRAN and OSI accepted license.
- [x] contains a README with instructions for installing the development version.
- [x] includes documentation with examples for all functions.
- [x] contains a vignette with examples of its essential functions and uses.
- [x] has a test suite.
- [x] has continuous integration, including reporting of test coverage using services such as Travis CI, Coveralls and/or CodeCov.

## Publication options

- [x] Do you intend for this package to go on CRAN?
- [ ] Do you wish to automatically submit to the [Journal of Open Source Software](http://joss.theoj.org/)? If so:

<details>
 <summary>JOSS Options</summary>

  - [ ] The package has an **obvious research application** according to [JOSS's definition](https://joss.readthedocs.io/en/latest/submitting.html#submission-requirements).
    - [ ] The package contains a `paper.md` matching [JOSS's requirements](https://joss.readthedocs.io/en/latest/submitting.html#what-should-my-paper-contain) with a high-level description in the package root or in `inst/`.
    - [ ] The package is deposited in a long-term repository with the DOI:
    - (*Do not submit your package separately to JOSS*)

</details>

- [ ] Do you wish to submit an Applications Article about your package to [Methods in Ecology and Evolution](http://besjournals.onlinelibrary.wiley.com/hub/journal/10.1111/(ISSN)2041-210X/)? If so:

<details>
<summary>MEE Options</summary>

- [ ] The package is novel and will be of interest to the broad readership of the journal.
- [ ] The manuscript describing the package is no longer than 3000 words.
- [ ] You intend to archive the code for the package in a long-term repository which meets the requirements of the journal (see [MEE's Policy on Publishing Code](http://besjournals.onlinelibrary.wiley.com/hub/journal/10.1111/(ISSN)2041-210X/journal-resources/policy-on-publishing-code.html))
- (*Scope: Do consider MEE's [Aims and Scope](http://besjournals.onlinelibrary.wiley.com/hub/journal/10.1111/(ISSN)2041-210X/aims-and-scope/read-full-aims-and-scope.html) for your manuscript. We make no guarantee that your manuscript will be within MEE scope.*)
- (*Although not required, we strongly recommend having a full manuscript prepared when you submit here.*)
- (*Please do not submit your package separately to Methods in Ecology and Evolution*)
</details>

## Code of conduct

- [x] I agree to abide by [ROpenSci's Code of Conduct](https://github.com/ropensci/onboarding/blob/master/policies.md#code-of-conduct) during the review process and in maintaining my package should it be accepted.
