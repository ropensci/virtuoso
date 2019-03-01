Dear CRAN,

I'm pleased to submit my revisions of virtuoso package to CRAN. I summarize how I have 
addressed the issues you highlighted in my initial submission below.

- I have revised the title along the lines requested.
- I have revised the description along the lines requested.

- I affirm that the package only writes to locations that the user specifies.  

- All examples are wrapped in dontrun because they take more than 5 seconds to run,
or require the presence of the external Virtuoso Database server to be started.
Note that it is not true that "nothing gets tested", as you will notice the extensive
test suite provided in tests/ directory.  Not all of these tests can run on CRAN's
systems because of the system requirement of accessing a running Virtuoso Database
server, but compatible tests are run, and the full suite of tests is run by the package's
continuous integration system on both Linux and Windows architectures where a 
Virtuoso server can be set up.  You will find links in the README to these CI systems,
as well as links showing the overall Code Coverage of the tests (on Linux, actual
coverage is higher because these tests omit the Windows-specific tests run on Appveyor).

This approach to testing is consistent with existing database packages hosted on CRAN,
such as RMariaDB, which skip tests when the external database server is not available.  

Thanks for your diligence and service to our community!

Sincerely,

Carl Boettiger
