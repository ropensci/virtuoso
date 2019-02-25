
message("Running one-time install of Virtuoso for tests...")
wait <- !has_virtuoso()

if (identical(Sys.getenv("NOT_CRAN"), "true"))
  vos_install(ask = FALSE)
if (wait) Sys.sleep(20)

