
create_virtuoso <- function(datadir = "virtuoso-data") {
  if (!requireNamespace("stevedore", quietly = TRUE)) {
    stop("Package stevedore must be installed to use this function")
  }

  dir.create(datadir, FALSE)
  stopifnot(stevedore::docker_available())
  docker <- stevedore::docker_client()
  docker$container$run("tenforce/virtuoso:1.3.1-virtuoso7.2.2",
    detach = TRUE,
    volumes = paste0(normalizePath(datadir), ":/var/data"),
    env = c(
      "SPARQL_UPDATE" = "true",
      "DEFAULT_GRAPH" = "http://www.example.com/my-graph",
      "DBA_PASSWORD" = "dba",
      "VIRT_Parameters_DirsAllowed" = "/var/data"
    ),
    ports = "1111:1111"
  )
}
