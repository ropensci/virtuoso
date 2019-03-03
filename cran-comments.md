Dear CRAN,

I'm pleased to submit my re-revisions of virtuoso package to CRAN. I summarize how I have 
addressed the issues you highlighted in my initial submission below.
.
- I affirm that the package only writes to locations that the user specifies.  
- I have now avoided the dontrun tests, using donttest where examples may take longer than 5 seconds,
  while allowing other tests to run where appropriate.
- Now every function includes an example in the documentation. Every function includes a minimal example 
where possible, however, as i have previously explained, like all database packages, many functions require
an external actively running Virtuoso database to connect to, which is not available on the CRAN platforms, 
and even when available can take over 5 seconds to establish connection.  Further note that examples in the 
documentation are not intended to take the place of *testing* the package, but serve the purpose of *documenting*
it.  The package has an extensive unit test suite which confirms the behavior of the package, not only that
the code runs without error, and indeed verifies that error or warning messages are displayed when expected.
I am thus still confused by the repeated and exclusive refferal to the examples as tests.  I appreciate the importance
of running examples whenever possible, but this serves the purpose of testing the documentation, and not the
package. 
  
My apologies for these issues and thanks for your patience and your service to our community!

Sincerely,

Carl Boettiger
