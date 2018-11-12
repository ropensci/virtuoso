context("test vos_query")

vos_start()



test_that("We can connect, bulk load and query", {


  con <- vos_connect()
  expect_is(con, "OpenLink Virtuoso")
  expect_is(con, "OdbcConnection")

  ex <- DBI::dbGetQuery(con, "SPARQL SELECT * WHERE { ?s ?p ?o } LIMIT 10")

  expect_equal(dim(ex)[1], 10)

  example <- system.file("extdata", "person.nq", package = "virtuoso")
  # Tests with alternative temp location:
  #vos_import(con, example, wd = rappdirs::user_cache_dir("Virtuoso"))
  vos_import(con, example)

  Sys.sleep(5)
  query <- "SELECT ?p ?o
     WHERE { ?s ?p ?o .
             ?s a <http://schema.org/Person>
            }"
  df <- vos_query(con, query)
  expect_equal(dim(df), c(5,2))
  expect_true(any(grepl("Jane Doe", df)))


  vos_list_graphs(con)
  vos_count_triples(con)

### After data is cleared, cannot re-load it w/o restarting server first...
### "We can clear all data",
  vos_clear_graph(con)
  df2 <- vos_query(con, query)
  expect_equal(dim(df2), c(0,2))


})

vos_kill()




