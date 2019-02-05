#  @importFrom utils askYesNo  ## Do not import, breaks in R 3.4
vos_install_osx <-
  function(use_brew = has_homebrew(),
             ask = is_interactive()) {
    if (use_brew) {
      vos_install_formulae()
    } else if (!ask && has_homebrew()) {
      vos_install_formulae()
    } else {
      vos_install_dmg()
    }
  }



download_osx_installer <- function() {
  download_url <- paste0(
    "https://sourceforge.net/projects/virtuoso/",
    "files/virtuoso/7.2.5/virtuoso-opensource-",
    "7.2.5-macosx-app.dmg"
  )
  fallback_url <- paste0(
    "https://github.com/cboettig/virtuoso/releases/",
    "download/v0.1.1/Virtuoso_OpenSource_7.20.dmg"
  )
  installer <- tempfile("virtuoso", fileext = ".dmg")
  message(paste("downloading Virtuoso dmg", "..."))
  download_fallback(download_url, installer, fallback_url)
  installer
}


download_fallback <- function(url, dest, fallback_url) {
  req <- curl::curl_fetch_disk(url, dest)
  if (req$status_code > 300) curl::curl_download(fallback_url, dest)
}


vos_install_dmg <- function() {
  dmg <- download_osx_installer()
  processx::run("open", dmg)

  ## User must then launch Virtuoso database from the taskbar.
  ## Installs Virtuoso home at:
  ## need to link $VIRTUOSO_HOME/bin/virtuoso-t

  askYesNo("Drag or copy Virtuoso into your Applications directory, then
           press return to continue...")
}




vos_install_formulae <- function(has_unixodbc = FALSE) {
  install_brew()

  ## Avoid possible brew install  error:

  ## Error: Cannot install virtuoso because conflicting formulae are installed.
  ## unixodbc: because Both install `isql` binaries.
  ## Please `brew unlink unixodbc` before continuing.
  ## Unlinking removes a formula's symlinks from /usr/local. You can
  ## link the formula again after the install finishes. You can --force this
  ## install, but the build may fail or cause obscure side-effects in the
  ## resulting software.

  ## Manually renaming the conflict does not stop brew from complaining :-(
  # if (has_unixodbc | file.exists("/usr/local/bin/isql")){
  #  has_unixodbc <- TRUE
  #  file.rename("/usr/local/bin/isql", "/usr/local/bin/isql-unixodbc")
  # }


  ## BREW is incredibly stupid in that it would rather we unlink unixodbc
  ## entirely, thus breaking ODBC functionality (e.g. odbcinst -j, which
  ## we use elsewhere in this package), than simply swap out the `isql`
  ## binary in `odbc` for that in `virtuoso` (or vice versa)
  ## Here, we force the install to avoid unlinking all of unixodbc
  ## We then link odbc with overwrite over `isql`.  Sadly, `link` also
  ## lacks the compliment of `overwrite` to skip already-installed binaries.
  processx::run("brew", c("install", "--force", "virtuoso"),
    error_on_status = FALSE
  )
  processx::run("brew", c("link", "--overwrite", "virtuoso"),
    error_on_status = FALSE
  )
}

has_homebrew <- function() !(Sys.which("brew") == "")

install_brew <- function() {
  if (!has_homebrew()) {
    processx::run("/usr/bin/ruby", paste(
      '-e "$(curl -fsSL',
      paste0(
        "https://raw.githubusercontent.com/",
        'Homebrew/install/master/install)"'
      )
    ))
  }
}




vos_uninstall_osx <- function() {
  out <- "no installation path found"
  if (has_homebrew()) {
    has_virt <- processx::run("brew", c("ls", "--versions", "virtuoso"),
      error_on_status = FALSE
    )
    if (has_virt$status == 0) {
      p <- processx::run("brew", c("uninstall", "virtuoso"),
        error_on_status = FALSE
      )
      out <- p$stdout
    }
  }

  if (file.exists(virtuoso_home_osx())) {
    unlink(virtuoso_home_osx(app = TRUE),
      recursive = TRUE
    )
    out <- paste("removed", virtuoso_home_osx(app = TRUE))
  }
  message(out)
  invisible(TRUE)
}

## an override-able interactive check
is_interactive <- function() {
  as.logical(Sys.getenv("INTERACTIVE", interactive()))
}
