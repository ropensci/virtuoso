context("vos install")

test_that("Virtuoso is installed", {

  virtuoso:::vos_set_path()
  expect_message(vos_install(), "Virtuoso already installed")

})

test_that("We can download installers", {

  skip_on_cran() ## slow download
  dmg <- download_osx_installer()
  expect_true(file.exists(dmg))

  exe <- download_windows_installer()
  expect_true(file.exists(exe))

})
