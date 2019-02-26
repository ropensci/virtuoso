context("vos_configure")

test_that("We can create a custom virtuoso.ini file", {

  skip_on_cran()
  ini <- vos_configure()
  expect_true(file.exists(ini))
  parsed <- ini::read.ini(ini)
  expect_is(parsed, "list")
})
