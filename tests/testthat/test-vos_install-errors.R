context("vos install errors")


#
# Platform-specific tests are hard to evaluate on Linux-based CI
#

test_that("We can download the windows installer", {

  skip_on_cran()

  virtuoso:::download_windows_installer()

  })


test_that("We can set the correct paths on windows", {

  skip_on_cran()

  virtuoso:::vos_set_path_windows()
  expect_true(grepl("Virtuoso", Sys.getenv("PATH")))

})


test_that("We get errors running windows installer on non-windows",
          {
            skip_on_cran()
            skip_on_os("windows")
            expect_error(virtuoso:::vos_install_windows())
            expect_error(vos_uninstall_windows())
          })


test_that("We get errors running mac installer on non-mac",
          {
            skip_on_cran()
            skip_on_os("mac")
            expect_error(virtuoso:::vos_install_osx())
            expect_error(virtuoso:::vos_install_osx(TRUE))

            ## remarkably / scarily, this doesn't throw an error...
            #expect_error(virtuoso:::install_brew())


          })

test_that("We get error message on linux install", {

  ## only run by vos_install() if `virtuoso-t` not found in PATH

  expect_error(virtuoso:::vos_install_linux())
})
