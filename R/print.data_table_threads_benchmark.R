#' Function to concisely display the results returned by \code{findOptimalThreadCount()} in an organized table
#'
#' @param x A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
#'
#' @param ... Additional arguments (not used in this function but included for consistency with the S3 generic \code{print} function).
#'
#' @return NULL.
#'
#' @details Prints a table enlisting the best performing thread count along with the runtime (median value) for each benchmarked \code{data.table} function.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Finding the best performing thread count for each benchmarked data.table function with a data size of 1000 rows and 10 columns:
#' benchmarkData <- findOptimalThreadCount(1000, 10)
#' # Printing the data:
#' benchmarkData
#' }

print.data_table_threads_benchmark <- function(x, ...)
{
  dt <- as.data.table(x)
  setnames(dt, c("threadCount", "expr", "medianTime"))

  fastestMedianTime <- dt[, .(medianTime = min(medianTime)), by = expr]
  bestPerformingThreadCount <- dt[fastestMedianTime, on = .(expr, medianTime), .(expr, threadCount, medianTime)]
  results <- bestPerformingThreadCount

  cat(sprintf("%-20s %-23s %-12s\n", "data.table function", "Fastest runtime (median)", "Thread count"))
  cat(rep("-", 29), "\n")

  for (i in seq_len(nrow(results)))
  {
    cat(sprintf("%-20s %-23f %-12d\n", results$expr[i], results$medianTime[i], results$threadCount[i]))
  }
}