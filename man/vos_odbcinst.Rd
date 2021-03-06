% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vos_odbcinst.R
\name{vos_odbcinst}
\alias{vos_odbcinst}
\title{Configure the ODBC Driver for Virtuoso}
\usage{
vos_odbcinst(
  system_odbcinst = find_odbcinst(),
  local_odbcinst = odbcinst_path()
)
}
\arguments{
\item{system_odbcinst}{Path to the system \code{odbcinst.ini} file. (Does not
require write access.) Default will attempt to find the file for your system.}

\item{local_odbcinst}{Path to the local odbcinst we should use.}
}
\value{
the path to the odbcinst file that is created or modified.
}
\description{
ODBC uses an \code{odbcinst.ini} file to point ODBC at the library required
to drive any given database.  This function helps us automatically
locate the driver library on different operating systems and configure
the odbcinst appropriately for each OS.
}
\details{
This function is called automatically by \code{\link[=vos_install]{vos_install()}} and thus
does not usually need to be called by the user.  Users can also manually
configure ODBC as outlined in
\url{https://github.com/r-dbi/odbc#dsn-configuration-files}.
This is merely a convenience function automating that process on most
systems.
}
\examples{
\donttest{
## Configures ODBC and returns silently on success.
vos_odbcinst()

## see where the inst file is located:
inst <- vos_odbcinst()
inst
}
}
