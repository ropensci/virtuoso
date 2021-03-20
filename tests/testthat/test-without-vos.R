context("tests that do not need a server connection")

test_that("vos_process errors when not cached", {
  skip_on_os("solaris")
  tryCatch(suppressMessages(vos_kill()),
           error = function(e) NULL,
           finally = NULL)
  expect_message(vos_kill(), "No active virtuoso")
  expect_null(vos_status())
  expect_identical(vos_process(), NA)
})
