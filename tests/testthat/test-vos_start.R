context("vos_start")


test_that("we can start a vos server and check status",{

  ## Unclear if CRAN can support this.
  skip_on_cran()

  # vos_start can take a while, so avoid tests that involve starting repeatedly.
  p <- vos_start()
  #expect_message(vos_start())
  expect_is(p, "ps_handle")
  expect_true(vos_status() %in% c("sleeping", "running"))

  ## We can access process handle independently
  p2 <- vos_process()
  expect_is(p2, "ps_handle")

  ## vos_status responds correctly
  expect_true(vos_status(p) %in% c("sleeping", "running"))
  ps_suspend(p)
  expect_equal(vos_status(p), "stopped")

  expect_length(vos_log(just_errors = TRUE), 0)

  vos_kill(p)
  expect_message(status <- vos_status())
  expect_null(status)

})

