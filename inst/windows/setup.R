library(processx)

virtuoso_home <- "C:/Program\ Files/OpenLink\ Software/Virtuoso OpenSource 7.20"
ini <- normalizePath(file.path(virtuoso_home, "database", "virtuoso.ini"))
bin <- file.path(virtuoso_home, "bin", "virtuoso-t"), mustWork = FALSE)

setwd(virtuoso_home)
setwd("bin")
getwd()

file.copy(ini, "virtuoso.ini")
p <- run("cat", ini)
cat(p$stdout)


system(paste("virtuoso-t", "-?"))
run(normalizePath()



safe_ini <- gsub(" ", "\\\\ ", ini)
system(paste("virtuoso-t", "-f", "-c", safe_ini))

run("virtuoso-t", c("-f", "-c", ini))


err <- tempfile("vos_start", fileext = ".log")

p <- processx::process$new("virtuoso-t", c("-f", "-c", ini),
                           stderr = err, stdout = "|",
                           cleanup = TRUE)


run("virtuoso-t", "-?")
system2("virtuoso-t", )
system("virtuoso-t -?")
