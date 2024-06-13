#' Function to set the thread count for a specific \code{data.table} function
#'
#' @param benchmarkData A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
#'
#' @param funcName The name of the \code{data.table} function for which to set the thread count.
#'
#' @return NULL.
#'
#' @details Sets the thread count to either the optimal (fastest median runtime) or recommended value (default) based on the chosen type argument for the specified \code{data.table} function based on the results obtained from \code{findOptimalThreadCount()}.
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
#' setThreadCount(benchmarkData, "forder", "optimal")
#' getDTthreads()
#' # Setting the recommended thread count for the 'nafill' function:
#' setThreadCount(benchmarkData, "nafill", "recommended")
#' getDTthreads()
#' }

setThreadCount <- function(benchmarkData, functionName, type = "recommended")
{
  setDTthreads(
    if(type == "optimal")
    {
      fastestMedianTime <- benchmarkData[expr == functionName, .(median = min(median))]
      bestThreadCount <- benchmarkData[expr == functionName & median == fastestMedianTime$median, threadCount]
      cat(sprintf("The number of threads that data.table will use has been set to %d, the thread count that achieved the best runtime for data.table::%s() based on the performed benchmarks.\n", bestThreadCount, functionName))

    }
    else if(type == "recommended")
    {
      if(!"speedup" %in% colnames(benchmarkData))
      {
        benchmarkData[, speedup := median[threadCount == 1] / median, by = expr]
      }
      recommendedSpeedupSubset <- benchmarkData[expr == functionName & type == "recommended"]
      merged <- benchmarkData[expr == functionName][recommendedSpeedupSubset, on = .(threadCount), nomatch = 0L]
      closestPoint <- benchmarkData[expr == functionName][which.max(speedup - merged$speedup)]
      recommendedThreadCount <- closestPoint$threadCount
      cat(sprintf("The number of threads that data.table will use has been set to %d, the recommended thread count for data.table::%s() based on the performed benchmarks.\n", recommendedThreadCount, functionName))
    }
    else
    {
      stop("Invalid type specified. (Please use 'recommended' or 'optimal')")
    }
  )
}
