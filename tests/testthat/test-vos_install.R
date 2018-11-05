context("vos install")

test_that("Virtuoso is installed", {

  expect_message(vos_install(), "virtuoso already installed")

})
