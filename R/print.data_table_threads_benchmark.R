#' Function to concisely display the results returned by \code{findOptimalThreadCount()} in an organized table
#'
#' @param x A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
#'
#' @param ... Additional arguments (not used in this function but included for consistency with the S3 generic \code{print} function).
#'
#' @return NULL.
#'
#' @details Prints a table enlisting the best performing thread count along with the runtime (median value) for each benchmarked function.
#'
#' @export
#'
#' @importFrom stats median
#'
#' @examples
#' # Finding the best performing thread count for each benchmarked data.table function
#' # with a data size of 1000 rows and 10 columns:
#' (benchmarkData <- data.table.threads::findOptimalThreadCount(1e3, 10))

print.data_table_threads_benchmark <- function(x, ...)
{
  fastestMedianTime <- x[, .(median = min(median)), by = expr]
  bestPerformingThreadCount <- x[fastestMedianTime, on = .(expr, median), .(expr, threadCount, median)]
  results <- bestPerformingThreadCount

  cat(sprintf("%-20s %-12s %-23s\n", "Function", "Thread count", "Fastest median runtime (ms)"))
  cat(rep("-", 31), "\n")

  for (i in seq_len(nrow(results)))
  {
    cat(sprintf("%-20s %-12d %-23f\n", results$expr[i], results$threadCount[i], results$median[i]))
  }
}
