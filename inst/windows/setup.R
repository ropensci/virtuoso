library(processx)

virtuoso_home <- "C:/Program\ Files/OpenLink\ Software/Virtuoso OpenSource 7.20"
ini <- normalizePath(file.path(virtuoso_home, "database", "virtuoso.ini"))
bin_cmd <- normalizePath(file.path(virtuoso_home, "bin", "virtuoso-t"), mustWork = FALSE)
bin_dir <- normalizePath(file.path(virtuoso_home, "bin"))

file.copy(ini, "inst/windows/virtuoso.ini")
err <- tempfile("vos_start", fileext = ".log")

local_ini <- normalizePath("inst/windows/virtuoso.ini")

p <- processx::process$new(bin_cmd, c("-f", "-c", local_ini),
                           stderr = err, stdout = "|",
                           cleanup = TRUE)


# Test (unrecognized arg causes help to print, also throws an error status)
run(bin_cmd, "-H", error_on_status = FALSE)
