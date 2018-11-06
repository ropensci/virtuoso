context("dplyr-like DSL")



test_that("we can construct some sparql select and fitler operations",{


  query <-
    sparql_op() %>%
    select.vos("identifier", "license", prefix = "http://schema.org/") %>%
    filter.vos(author.familyName == "Boettiger",
               author.givenName == "Carl",
               prefix = "http://schema.org/") %>%
    sparql_build(na.rm = FALSE)

  expect_is(query, "sparql")


  query <-
    sparql_op() %>%
    select.vos(package = "name", "license", "author.familyName", "author.givenName",
               co = "author.familyName",
               prefix = "http://schema.org/") %>%
    filter.vos( author.givenName == "Carl",
                author.familyName == "Boettiger",
                prefix = "http://schema.org/") %>%
    sparql_build()

  expect_is(query, "sparql")
  expect_output(print(query), "SELECT")

  predicate_filter("license", prefix = "schema:")

})
