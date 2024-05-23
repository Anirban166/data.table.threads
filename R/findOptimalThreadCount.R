#' Function that finds the optimal (fastest) thread count for different \code{data.table} functions
#'
#' This function finds the optimal thread count for running \code{data.table} functions with maximum efficiency.
#'
#' @param rowCount The number of rows in the \code{data.table}.
#'
#' @param colCount The number of columns in the \code{data.table}.
#'
#' @param times The number of times the benchmarks are to be run.
#'
#' @param verbose Option (logical) to enable or disable detailed message printing.
#'
#' @return A \code{data.table} of class \code{data_table_threads_benchmark} containing the optimal thread count for each \code{data.table} function.
#'
#' @details Iteratively runs benchmarks with increasing thread counts and determines the optimal number of threads for each \code{data.table} function.
#'
#' @export
#'
#' @import data.table
#' @import microbenchmark
#'
#' @examples
#' \dontrun{
#' # Finding the best performing thread count for each benchmarked data.table function with a data size of 1000 rows and 10 columns:
#' optimalThreads <- data.table.threads::findOptimalThreadCount(1000, 10)
#' }

findOptimalThreadCount <- function(rowCount, colCount, times = 10, verbose = TRUE)
{
  setDTthreads(0)
  maxThreads <- getDTthreads()
  results <- list()

  for (threadCount in 1:maxThreads) {
    results[[threadCount]] <- runBenchmarks(rowCount, colCount, threadCount, times, verbose)
  }

  results.dt <- rbindlist(results)
  setattr(results.dt, "class", c("data_table_threads_benchmark", class(results.dt)))
  results.dt
}
