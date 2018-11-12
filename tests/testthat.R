library(testthat)
library(virtuoso)

vos_install()

Sys.sleep(60) # Give the installer a minute to finish...
test_check("virtuoso")
