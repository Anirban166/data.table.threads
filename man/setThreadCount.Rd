% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setThreadCount.R
\name{setThreadCount}
\alias{setThreadCount}
\title{Function to set the thread count for a specific \code{data.table} function}
\usage{
setThreadCount(
  benchmarkData,
  functionName,
  efficiencyFactor = 0.5,
  verbose = FALSE
)
}
\arguments{
\item{benchmarkData}{A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.}

\item{functionName}{The name of the \code{data.table} function for which to set the thread count.}

\item{efficiencyFactor}{A numeric value between 0 and 1 indicating the desired efficiency level for thread count selection. 0 represents use of the optimal thread count (lowest median runtime) and 0.5 represents the recommended thread count.}

\item{verbose}{Option (logical) to enable or disable detailed message printing.}
}
\value{
NULL.
}
\description{
Function to set the thread count for a specific \code{data.table} function
}
\details{
Sets the thread count to either the optimal (fastest median runtime) or recommended value (default) based on the chosen type argument for the specified \code{data.table} function based on the results obtained from \code{findOptimalThreadCount()}.
}
\examples{
# Finding the best performing thread count for each benchmarked data.table function
# with a data size of 1000 rows and 10 columns:
benchmarkData <- data.table.threads::findOptimalThreadCount(1e3, 10)
# Setting the optimal thread count for the 'forder' function:
setThreadCount(benchmarkData, "forder", efficiencyFactor = 1)
# Can verify by checking benchmarkData and getDTthreads():
data.table::getDTthreads()
}
