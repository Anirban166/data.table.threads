#' Function to set the optimal thread count for a specific \code{data.table} function
#'
#' @param benchmarkData A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
#'
#' @param functionName The name of the \code{data.table} function for which to set the optimal thread count.
#'
#' @return NULL.
#'
#' @details Sets the thread count to the optimal value (fastest median runtime) for the specified \code{data.table} function based on the results obtained from \code{findOptimalThreadCount()}.
#'
#' @export
#'
#' @import data.table
#'
#' @examples
#' \dontrun{
#' # Finding the best performing thread count for each benchmarked data.table function with a data size of 10000000 rows and 10 columns:
#' benchmarkData <- data.table.threads::findOptimalThreadCount(1e7, 10)
#' # Setting the optimal thread count for the 'forder' function:
#' setOptimalThreadCount(benchmarkData, "forder")
#' }

setOptimalThreadCount <- function(benchmarkData, functionName)
{
  fastestMedianTime <- benchmarkData[expr == functionName, .(median = min(median)), by = expr]
  bestThreadCount <- benchmarkData[fastestMedianTime, on = .(expr, median), threadCount]

  setDTthreads(bestThreadCount)
  cat(sprintf("The number of threads that data.table will use has been set to %d, the thread count that achieved the best runtime for data.table::%s().\n", bestThreadCount, functionName))
}
