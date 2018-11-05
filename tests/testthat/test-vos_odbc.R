context("Detecting ODBC Drivers")

test_that("We can detect ODBC drivers", {
  path <- virtuoso:::find_driver()
  expect_is(path, "character")
  expect_true(file.exists(path))

})

test_that("We can find odbcinst.ini file", {

  path <- virtuoso:::find_odbcinst()
  expect_is(path, "character")
  expect_gt(length(path), 0)
  # Note, if odbcinst -j not available,
  # fallback will returns a path to "~/.odbcinst.ini"
})

test_that("We can generate an odbcinst file", {

  path <- virtuoso:::vos_odbcinst()
  expect_is(path, "character")
  expect_gt(length(path), 0)
  expect_true(file.exists(path))

})
