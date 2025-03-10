% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check.key.R
\name{check.key}
\alias{check.key}
\title{Check Index Key}
\usage{
check.key(x, ...)
}
\arguments{
\item{x}{Object.}

\item{key}{Character string specifying an index key.}

\item{echo}{Logical value specifying whether to print error messages to the R console.}
}
\value{
A character vector of error messages (invisible).
}
\description{
Checks whether a data frame's index key is unique or contains any missing values. 
             An index key may be a single or combination of variables which uniquely identify data 
             rows in a table. Index keys are important for merging data tables.
}
\examples{
# Vector example:
x <- rpois(20, 5)
check.key(x) # Checks for repeat entries.

x <- data.frame(year = sample(2010:2014, 20, replace = TRUE),
                site = sample(LETTERS[1:5], 20, replace = 20),
                count = rpois(20, 5),
                value = rnorm(20))
x$year[sample(1:nrow(x), 3)] <- NA
check.key(x, key = c("year", "site"))

}
