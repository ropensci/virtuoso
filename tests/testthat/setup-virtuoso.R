

testthat::setup({
message("Running one-time install of Virtuoso for tests...")
wait <- !has_virtuoso()

# testthat::skip_on_cran()
# if (identical(Sys.getenv("NOT_CRAN"), "true"))
  vos_install(ask = FALSE)
if (wait) Sys.sleep(20)

})
