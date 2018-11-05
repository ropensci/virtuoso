context("write nquads")


test_that("We can write nquads from a data frame", {
  tmp <- tempfile()
  write_nquads(iris, tmp, prefix = "iris")
  expect_true(file.exists(tmp))
})
