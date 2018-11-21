
#' @importFrom rappdirs app_dir
virtuoso_app <- rappdirs::app_dir("Virtuoso")


virtuoso_home <- function(){
  switch(which_os(),
         osx = virtuoso_home_osx(),
         windows = virtuoso_home_windows(),
         linux = "/etc/virtuoso-opensource-6.1/virtuoso.ini",
         NULL
  )
}


brew_home <- function(){
  if(!has_homebrew()) return("")
  cmd <- processx::run("brew", c("--prefix", "virtuoso"))
  cmd$stdout
}

virtuoso_home_osx <- function(app = FALSE, use_brew = FALSE){
  brewhome <- brew_home()
  if(file.exists(brewhome) || use_brew){
    system_home <- brewhome
  } else {
    system_home <-
      paste0("/Applications/Virtuoso Open Source Edition v7.2.app/",
             "Contents/virtuoso-opensource")
  }
  home <- Sys.getenv("VIRTUOSO_HOME", system_home)


  if(app) return(normalizePath(file.path(home, "..", ".."), mustWork = FALSE))
  home
}

virtuoso_home_windows <- function(){
  system_home <- "C:/Program\ Files/OpenLink\ Software/Virtuoso OpenSource 7.20"
  Sys.getenv("VIRTUOSO_HOME", system_home)
}
