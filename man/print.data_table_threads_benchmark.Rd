% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print.data_table_threads_benchmark.R
\name{print.data_table_threads_benchmark}
\alias{print.data_table_threads_benchmark}
\title{Function to concisely display the results returned by \code{findOptimalThreadCount()} in an organized table}
\usage{
\method{print}{data_table_threads_benchmark}(x, ...)
}
\arguments{
\item{x}{A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.}

\item{...}{Additional arguments (not used in this function but included for consistency with the S3 generic \code{print} function).}
}
\value{
NULL.
}
\description{
Function to concisely display the results returned by \code{findOptimalThreadCount()} in an organized table
}
\details{
Prints a table enlisting the best performing thread count along with the runtime (median value) for each benchmarked \code{data.table} function.
}
\examples{
# Finding the best performing thread count for each benchmarked data.table function
# with a data size of 1000 rows and 10 columns:
(benchmarkData <- data.table.threads::findOptimalThreadCount(1e3, 10))
}
