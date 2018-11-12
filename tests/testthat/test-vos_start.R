context("vos_start")


test_that("we can start a vos server and check status",{

  ## Unclear if CRAN can support this.
  # skip_on_cran()

  # vos_start can take a while, so avoid tests that involve starting repeatedly.
  p <- vos_start()
  expect_message(vos_start(), "Found existing")
  expect_is(p, "process")
  expect_true(p$get_status() %in% c("sleeping", "running"))

  ## We can access process handle independently
  p2 <- vos_process()
  expect_identical(p, p2)

  ## vos_status responds correctly
  expect_true(vos_status(p) %in% c("sleeping", "running"))
  p$suspend()
  expect_equal(vos_status(p), "stopped")

  expect_length(vos_log(just_errors = TRUE), 0)

  vos_kill(p)
  expect_warning(status <- vos_status(p),
                 "Server is not alive")
  expect_equal(status, "dead")

})

