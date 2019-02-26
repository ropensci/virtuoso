

testthat::setup({

  if (identical(Sys.getenv("NOT_CRAN"), "true")){

    message("Running one-time install of Virtuoso for tests...")
    wait <- !has_virtuoso()
    vos_install(ask = FALSE)
    if (wait) Sys.sleep(120)
  }

})
