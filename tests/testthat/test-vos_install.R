context("vos install")

test_that("Virtuoso is installed", {
  skip_on_os("solaris")
  skip_if_not(has_virtuoso())
  virtuoso:::vos_set_path()
  expect_message(
    vos_install(ask = FALSE),
    "Virtuoso is already installed."
  )
})

test_that("We can download installers", {
  skip_on_os("mac") # slow download, annoying for local testing.
  skip_on_os("windows")
  skip_on_os("solaris")

  skip_on_cran() ## slow download
  dmg <- download_osx_installer()
  expect_true(file.exists(dmg))

  exe <- download_windows_installer()
  expect_true(file.exists(exe))
})
