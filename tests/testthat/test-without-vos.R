context("tests that do not need a server connection")

test_that("vos_process errors when not cached", {

  expect_warning(vos_status())

  expect_warning(vos_process())
#  "No virtuoso process found. Try starting one with vos_start()")
})
