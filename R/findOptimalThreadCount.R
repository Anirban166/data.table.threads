#' Function that finds the optimal (fastest) thread count for different data.table functions
#'
#' This function finds the optimal thread count for running data.table functions with maximum efficiency.
#'
#' @param rowCount The number of rows in the data table.
#'
#' @param colCount The number of columns in the data table.
#'
#' @return A data frame containing the optimal thread count for each data.table function.
#'
#' @details Iteratively runs benchmarks with increasing thread counts and determines the optimal number of threads for each data.table function.
#'
#' @export
#'
#' @import data.table
#' @import microbenchmark
#'
#' @examples
#' \dontrun{
#' # Finding the best performing thread count for each benchmarked data.table function with a data size of 1000 rows and 10 columns:
#' optimalThreads <- findOptimalThreadCount(1000, 10)
#' }

findOptimalThreadCount <- function(rowCount, colCount) {

  setDTthreads(0)
  maxThreads <- getDTthreads()
  results <- list()

  for (threadCount in 1:maxThreads) {
    results[[threadCount]] <- runBenchmarks(rowCount, colCount, threadCount)
  }

  result.list <- do.call(rbind, results)
  class(result.list) <- "data_table_threads_benchmark"
  result.list
}
