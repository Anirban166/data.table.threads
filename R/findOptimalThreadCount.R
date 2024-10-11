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
#' # Finding the best performing thread count for each benchmarked data.table function
#' # with a data size of 1000 rows and 10 columns:
#' (optimalThreads <- data.table.threads::findOptimalThreadCount(1e3, 10))

findOptimalThreadCount <- function(rowCount, colCount, times = 10, verbose = FALSE)
{
  setDTthreads(0)
  systemThreadCount <- getDTthreads()
  results <- list()

  for(threadCount in 1:systemThreadCount) 
  {
    results[[threadCount]] <- runBenchmarks(rowCount, colCount, threadCount, times, verbose)
  }

  results.dt <- rbindlist(results)
  seconds.dt <- results.dt[, .(threadCount, expr, min, max, median)]
  functions <- unique(seconds.dt$expr)
  seconds.dt[, `:=`(speedup = median[threadCount == 1] / median, 
                    type = "Measured"), by = expr]

  # speedupData <- data.table(
  #   expr = rep(functions, each = systemThreadCount),
  #   threadCount = rep(c(1:systemThreadCount, seq(1, systemThreadCount, length.out = systemThreadCount)), length(functions)),
  #   speedup = c(rep(seq(1, systemThreadCount), length(functions)), rep(seq(1, systemThreadCount / 2, length.out = systemThreadCount), length(functions))),
  #   type = rep(c("Ideal", "Recommended"), each = systemThreadCount * length(functions))
  # )

  speedupData <- rbind(
    data.table(expr = rep(functions, each = systemThreadCount),
               threadCount = rep(1:systemThreadCount, length(functions)),
               speedup = rep(idealSpeedup, length(functions)),
               type = "Ideal"),
    data.table(expr = rep(functions, each = systemThreadCount),
               threadCount = rep(1:systemThreadCount, length(functions)),
               speedup = rep(recommendedSpeedup, length(functions)),
               type = "Recommended")
  )

  maxSpeedup <- seconds.dt[, .(threadCount = threadCount[which.max(speedup)], 
                               speedup = max(speedup), 
                               type = "Ideal"), 
                             by = expr]

  closestPoints <- seconds.dt[, {
    recommendedSubset <- speedupData[type == "Recommended" & threadCount %in% .SD$threadCount]
    validPoints <- .SD[speedup >= recommendedSubset$speedup]
    validPoints[validPoints[, which.max(speedup)], .SD[.SD[, .I], on = .(expr)], by = expr]
  }, by = expr]

  # Using fill = TRUE for missing columns minTime, maxTime, and median in speedupData and maxSpeedup:
  combinedLineData <- rbind(speedupData, seconds.dt, fill = TRUE)
  combinedPointData <- rbind(maxSpeedup, closestPoints, fill = TRUE)

  setattr(seconds.dt, "combinedLineData", combinedLineData)
  setattr(seconds.dt, "combinedPointData", combinedPointData)
  setattr(seconds.dt, "class", c("data_table_threads_benchmark", class(seconds.dt)))
  seconds.dt
}
