#' Function to set the thread count for a specific \code{data.table} function
#'
#' @param benchmarkData A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
#'
#' @param functionName The name of the \code{data.table} function for which to set the thread count.
#'
#' @param verbose Option (logical) to enable or disable detailed message printing.
#'
#' @param efficiencyFactor A numeric value between 0 and 1 indicating the desired efficiency level for thread count selection. 0 represents use of the optimal thread count (lowest median runtime) and 0.5 represents the recommended thread count.
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
#' # Finding the best performing thread count for each benchmarked data.table function
#' # with a data size of 1000 rows and 10 columns:
#' benchmarkData <- data.table.threads::findOptimalThreadCount(1e3, 10)
#' # Setting the optimal thread count for the 'forder' function:
#' setThreadCount(benchmarkData, "forder", efficiencyFactor = 1)
#' # Can verify by checking benchmarkData and getDTthreads():
#' getDTthreads()

setThreadCount <- function(benchmarkData, functionName, efficiencyFactor = 0.5, verbose = FALSE)
{
  if(!is.numeric(efficiencyFactor) || efficiencyFactor < 0 || efficiencyFactor > 1)
  {
    stop("Invalid efficiency factor. Please use a value between 0 and 1 (inclusive).")
  }

  if(!functionName %in% benchmarkData$expr)
  {
    stop("The specified function does not exist in data.table or is not supported here.")
  }  
  
  if(!"speedup" %in% colnames(benchmarkData))
  {
    benchmarkData[, speedup := median[threadCount == 1] / median, by = expr]
  }

  maxSpeedup <- max(benchmarkData[expr == functionName]$speedup)
  targetSpeedup <- efficiencyFactor * maxSpeedup
  benchmarkData[, diff := abs(speedup - targetSpeedup), by = expr]
  recommendedThreadCount <- benchmarkData[expr == functionName][order(diff)][1, threadCount]

  if(verbose) 
  {
    message("The number of threads that data.table will use has been set to ", recommendedThreadCount, ", based on an efficiency factor of ", efficiencyFactor, " for data.table::", functionName, "() based on the performed benchmarks.")
  }

  setDTthreads(recommendedThreadCount)
}
