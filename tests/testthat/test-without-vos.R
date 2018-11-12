context("tests that do not need a server connection")

test_that("vos_process errors when not cached", {

  expect_error(vos_status())

  expect_error(vos_process())
#  "No virtuoso process found. Try starting one with vos_start()")
})
