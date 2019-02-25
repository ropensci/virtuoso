

testthat::setup({
  message("Running one-time install of Virtuoso for tests...")
  wait <- !has_virtuoso()

  testthat::skip_on_cran()
  vos_install(ask = FALSE)
  if (wait) Sys.sleep(20)

})
