
is_osx <- function() unname(Sys.info()["sysname"] == "Darwin")

is_linux <- function() unname(Sys.info()["sysname"] == "Linux")

is_windows <- function() .Platform$OS.type == "windows"

is_solaris <-function() grepl('SunOS',Sys.info()['sysname'])

which_os <- function() {
  if (is_osx()) return("osx")
  if (is_linux()) return("linux")
  if (is_windows()) return("windows")
  if (is_solaris()) return("solaris")
  warning("OS could not be determined", call. = FALSE)
  NULL
}


# utils::askYesKnow is new to R 3.5.0; avoid for backwards compatibility
askYesNo <- function(msg) {
  prompts <- c("Yes", "No", "Cancel")
  choices <- tolower(prompts)
  msg1 <- paste0("(", paste(choices, collapse = "/"), ") ")

  if (nchar(paste0(msg, msg1)) > 250) {
    cat(msg, "\n")
    msg <- msg1
  }
  else {
    msg <- paste0(msg, " ", msg1)
  }

  ans <- readline(msg)
  match <- pmatch(tolower(ans), tolower(choices))

  if (!nchar(ans)) {
    TRUE
  } else if (is.na(match)) {
    stop("Unrecognized response ", dQuote(ans))
  } else {
    c(TRUE, FALSE, NA)[match]
  }
}
