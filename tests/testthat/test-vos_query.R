context("test vos_query")

testthat::setup({

  ## skip_on_cran() not applicable to setup blocks!
  if (identical(Sys.getenv("NOT_CRAN"), "true")){
    if(has_virtuoso())
    vos_start(wait = 120)
  }

})



test_that("We can connect, bulk load and query", {
  skip_on_cran()
  skip_on_appveyor()
  skip_if_not(has_virtuoso())

  ## We can access process handle independently
  p <- vos_process()
  # expect_is(p, "ps_handle")
  # expect_true(vos_status() %in% c("sleeping", "running"))

  expect_length(vos_log(just_errors = TRUE), 0)

  con <- vos_connect()
  expect_is(con, "OpenLink Virtuoso")
  expect_is(con, "OdbcConnection")

  ex <- DBI::dbGetQuery(con, "SPARQL SELECT * WHERE { ?s ?p ?o } LIMIT 10")

  expect_equal(dim(ex)[1], 10)

  example <- system.file("extdata", "person.nq", package = "virtuoso")
  # Tests with alternative temp location:
  vos_import(con, example, wd = tempdir())
  vos_import(con, example)

  Sys.sleep(5)
  query <- "SELECT ?p ?o
     WHERE { ?s ?p ?o .
             ?s a <http://schema.org/Person>
            }"
  df <- vos_query(con, query)
  expect_equal(dim(df), c(5, 2))
  expect_true(any(grepl("Jane Doe", df)))


  bad_file <- system.file("extdata", "bad_quads.nq", package = "virtuoso")
  expect_error(vos_import(con, bad_file))

  vos_list_graphs(con)
  ## not fully developed:
  #  virtuoso:::vos_count_triples(con)
  #  virtuoso:::vos_count_triples(con, "rdflib")

  ### After data is cleared, cannot re-load it w/o restarting server first...
  ### "We can clear all data",
  #  virtuoso:::vos_clear_graph(con)
  #  df2 <- vos_query(con, query)
  #  expect_equal(dim(df2), c(0,2))
})

testthat::teardown(vos_kill())
