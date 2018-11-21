library(testthat)
library(virtuoso)

Sys.setenv(INTERACTIVE = FALSE) # Overrides detected interactive behavior
test_check("virtuoso")
