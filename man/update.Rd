% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/update.R
\name{update}
\alias{update}
\alias{update.scsset}
\alias{update.scsbio}
\title{Update Data}
\usage{
\method{update}{scsset}(x, year, path = getwd(), package = TRUE, ...)

\method{update}{scsbio}(year, path = getwd(), ...)
}
\arguments{
\item{year}{Project year(s) to be updated.}

\item{path}{Character string specifying the path to read or write snow crab biological data.}

\item{Rfile}{Logical value specifying whether to write an \code{R} data format file when 
updating snow crab biological data.}

\item{csv}{Logical value specifying whether to write a comma-separated (\code{csv}) format file 
when updating snow crab biological data.}
}
\description{
Functions to update \code{gulf.data} package data.
}
\section{Methods}{

\describe{
   \item{\code{update.scsset}}{Create an \code{scsset} object.}
   \item{\code{update.scsbio}}{Update snow crab survey biological data repositories.}
}
}

\seealso{
\code{\link{scsset}}, \code{\link{scsbio}}
}
