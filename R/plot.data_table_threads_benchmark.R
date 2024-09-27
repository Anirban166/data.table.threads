#' Function to make speedup plots for the benchmarked \code{data.table} functions
#'
#' @param x A \code{data.table} of class \code{data_table_threads_benchmark} containing benchmarked timings with corresponding thread counts.
#'
#' @param ... Additional arguments (not used in this function but included for consistency with the S3 generic \code{plot} function).
#'
#' @return A \code{ggplot} object containing a speedup plot for each benchmarked \code{data.table} function.
#'
#' @details Creates a comprehensive \code{ggplot} showing the ideal, sub-optimal, and measured speedup trends for the \code{data.table} functions benchmarked with varying thread counts.
#'
#' @export
#'
#' @import ggplot2
#' @import data.table
#'
#' @examples
#' \dontrun{
#' # Finding the best performing thread count for each benchmarked data.table function
#' # with a data size of 10000000 rows and 10 columns:
#' benchmarkData <- data.table.threads::findOptimalThreadCount(1e7, 10)
#' # Generating speedup plots based on the data collected above:
#' plot(benchmarkData)
#' }

plot.data_table_threads_benchmark <- function(x, ...)
{
  x[, `:=`(speedup = median[threadCount == 1] / median, type = "Measured"), by = expr]

  setDTthreads(0)
  systemThreadCount <- getDTthreads()
  functions <- unique(x$expr)

  speedupData <- data.table(
    expr = rep(functions, each = systemThreadCount),
    threadCount = rep(c(1:systemThreadCount, seq(1, systemThreadCount, length.out = systemThreadCount)), length(functions)),
    speedup = c(rep(seq(1, systemThreadCount), length(functions)), rep(seq(1, systemThreadCount / 2, length.out = systemThreadCount), length(functions))),
    type = rep(c("Ideal", "Recommended"), each = systemThreadCount * length(functions))
  )

  maxSpeedup <- x[, .(threadCount = threadCount[which.max(speedup)], speedup = max(speedup), type = "Ideal"), by = expr]

  recommendedSpeedupData <- data.table(
    threadCount = seq(1, systemThreadCount, length.out = systemThreadCount),
    speedup = seq(1, systemThreadCount / 2, length.out = systemThreadCount),
    type = "Recommended"
  )
  
  closestPoints <- x[, {
    recommendedSubset <- recommendedSpeedupData[threadCount %in% .SD$threadCount]
    .SD[.SD$speedup >= recommendedSubset$speedup][which.max(speedup)]
  }, by = expr]
  closestPoints[, type := "Recommended"]
  
  # Using fill = TRUE for missing columns minTime, maxTime, and median in speedupData and maxSpeedup:
  combinedLineData <- rbind(speedupData, x, fill = TRUE)
  combinedPointData <- rbind(maxSpeedup, closestPoints, fill = TRUE)

  x[, `:=`(minSpeedup = min(speedup, na.rm = TRUE), maxSpeedup = max(speedup, na.rm = TRUE)), by = expr]

  ggplot(x, aes(x = threadCount, y = speedup)) +
    geom_line(data = combinedLineData, aes(color = type), size = 1) +
    geom_point(data = combinedPointData, aes(color = type), size = 3) +
    geom_text(data = combinedPointData, aes(label = threadCount), vjust = -0.5, size = 4, na.rm = TRUE) +
    facet_wrap(. ~ expr) +
    coord_equal() +
    labs(x = "Threads", y = "Speedup", title = "data.table functions") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = 1:systemThreadCount, labels = 1:systemThreadCount) +
    scale_color_manual(values = c("Measured" = "black", "Ideal" = "#f79494", "Recommended" = "#93c4e0")) +
    guides(color = guide_legend(title = "Type"))
}
